// Deploy in the DearJolly Google Apps Script project, never in the mobile app.
// Store the channel credential in the DISCORD_WEBHOOK_URL script property.
const CFG = {
  title: '디어졸리 문의하기',
  fields: ['답변받을 메일', '닉네임', '문의 종류', '핸드폰 기종', '문의 내용', '개인정보 수집·이용 동의'],
  extra: ['문의번호', '처리 상태', '디스코드 알림', '알림 전송시각', '운영 메모'],
};

function setup() {
  const p = PropertiesService.getScriptProperties();
  const ss = p.getProperty('SHEET_ID')
    ? SpreadsheetApp.openById(p.getProperty('SHEET_ID'))
    : SpreadsheetApp.create('디어졸리 문의 관리');
  p.setProperty('SHEET_ID', ss.getId());
  ss.setSpreadsheetTimeZone('Asia/Seoul');
  const form = p.getProperty('FORM_ID')
    ? FormApp.openById(p.getProperty('FORM_ID'))
    : FormApp.create(CFG.title, false);
  p.setProperty('FORM_ID', form.getId());

  if (!form.getItems().length) {
    form.setDescription('디어졸리를 이용하며 궁금하거나 불편했던 점을 알려주세요. 입력한 이메일로 답변드립니다. 비밀번호, 결제정보, 주민등록번호 등 민감한 정보는 적지 마세요.');
    form.addTextItem().setTitle(CFG.fields[0]).setRequired(true)
      .setHelpText('답변을 받을 수 있는 이메일을 정확히 입력해주세요.')
      .setValidation(FormApp.createTextValidation().requireTextIsEmail().build());
    form.addTextItem().setTitle(CFG.fields[1]).setRequired(true)
      .setHelpText('디어졸리에서 사용하는 닉네임')
      .setValidation(FormApp.createTextValidation().requireTextLengthLessThanOrEqualTo(50).build());
    form.addListItem().setTitle(CFG.fields[2]).setRequired(true)
      .setChoiceValues(['오류 및 버그', '계정 및 로그인', '편지 작성 및 교정', '기능 제안', '개인정보 및 탈퇴', '기타']);
    form.addTextItem().setTitle(CFG.fields[3]).setRequired(true)
      .setHelpText('예: iPhone 15 / iOS 18, Galaxy S24 / Android 15. 모르면 ‘모름’이라고 적어주세요.')
      .setValidation(FormApp.createTextValidation().requireTextLengthLessThanOrEqualTo(100).build());
    form.addParagraphTextItem().setTitle(CFG.fields[4]).setRequired(true)
      .setHelpText('어떤 화면에서 어떤 문제가 발생했는지, 재현 순서와 기대한 동작을 알려주세요. 최대 3,000자.')
      .setValidation(FormApp.createParagraphTextValidation().requireTextLengthLessThanOrEqualTo(3000).build());
    form.addCheckboxItem().setTitle(CFG.fields[5]).setRequired(true)
      .setHelpText('수집·이용 주체: 디어졸리 운영팀. 목적: 문의 접수·답변 및 오류 해결. 항목: 이메일, 닉네임, 문의 종류·내용, 휴대폰 기종, 접수시각. Google 설문지·시트에 저장하고 운영진용 Discord 채널로 전달합니다. 접수일로부터 1년 보관 후 삭제합니다. 동의를 거부할 수 있으나 이 문의 폼의 이용이 제한됩니다. 문의 및 철회: dearjolly.official@gmail.com')
      .setChoiceValues(['동의합니다']);
  }
  if (form.getItems().length !== CFG.fields.length) {
    throw new Error('문의 폼의 필수 여섯 항목을 확인하세요. 부분 생성된 폼을 자동으로 공개하지 않습니다.');
  }
  form.setCollectEmail(false).setLimitOneResponsePerUser(false)
    .setAllowResponseEdits(false).setPublishingSummary(false);
  form.setConfirmationMessage('문의가 접수되었습니다. 남겨주신 이메일로 답변드릴게요. 감사합니다!');
  // A newly created form throws when no destination exists yet.
  let destinationId = null;
  try { destinationId = form.getDestinationId(); } catch (_) {}
  if (destinationId !== ss.getId()) {
    form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());
  }
  SpreadsheetApp.flush();
  const sheet = ss.getSheets().find(s => s.getFormUrl());
  if (!sheet) throw new Error('응답 시트 생성 중입니다. 잠시 후 setup을 다시 실행하세요.');
  p.setProperty('RESPONSE_SHEET_ID', String(sheet.getSheetId()));
  sheet.setName('문의 접수');
  sheet.getRange(1, 8, 1, 5).setValues([CFG.extra]);
  sheet.setFrozenRows(1);
  sheet.getRange(1, 1, 1, 12).setBackground('#6F2037').setFontColor('#ffffff').setFontWeight('bold');
  sheet.setColumnWidths(1, 12, 155);
  sheet.setColumnWidth(2, 235);
  sheet.setColumnWidth(6, 430);
  sheet.setColumnWidth(12, 300);
  sheet.getRange('A:A').setNumberFormat('yyyy-mm-dd hh:mm');
  sheet.getRange('K:K').setNumberFormat('yyyy-mm-dd hh:mm');
  sheet.getRange('B:J').setWrap(true);
  sheet.getRange('L:L').setWrap(true);
  sheet.getRange(2, 9, sheet.getMaxRows() - 1, 1).setDataValidation(
    SpreadsheetApp.newDataValidation()
      .requireValueInList(['접수', '확인 중', '답변 완료', '보류'], true)
      .setAllowInvalid(false).build());
  if (!sheet.getFilter()) {
    try {
      sheet.getRange(1, 1, sheet.getMaxRows(), 12).createFilter();
    } catch (_) {
      // New Forms response tables can already own their filtering range.
      // Filtering is optional; it must not prevent trigger installation.
    }
  }

  const guide = ss.getSheetByName('운영 안내') || ss.getSheets().find(s => !s.getFormUrl()) || ss.insertSheet('운영 안내');
  guide.setName('운영 안내');
  guide.getRange(1, 1, 8, 2).setValues([
    ['디어졸리 문의 관리', ''],
    ['문의 폼', form.getPublishedUrl()],
    ['폼 편집', form.getEditUrl()],
    ['응답 관리', ss.getUrl()],
    ['처리 방법', '문의 접수 탭에서 처리 상태와 운영 메모를 수정하세요.'],
    ['알림 상태', '전송 대기 / 전송 완료 / 재시도 필요. 최대 10건씩 5분마다 재시도합니다.'],
    ['보관기간', '접수일로부터 1년. 지난 폼 응답, 시트 행, Discord 메시지는 운영자가 삭제해주세요.'],
    ['Discord 연결', '프로젝트 설정의 스크립트 속성 DISCORD_WEBHOOK_URL에 문의-알림 웹훅 주소를 저장하세요.'],
  ]);
  guide.setColumnWidth(1, 160);
  guide.setColumnWidth(2, 650);
  guide.getRange('A1:B8').setWrap(true);
  guide.getRange('A1:B1').setBackground('#6F2037').setFontColor('#ffffff').setFontWeight('bold');
  const names = ScriptApp.getProjectTriggers().map(t => t.getHandlerFunction());
  if (!names.includes('onInquirySubmit')) ScriptApp.newTrigger('onInquirySubmit').forSpreadsheet(ss).onFormSubmit().create();
  if (!names.includes('retryNotifications')) ScriptApp.newTrigger('retryNotifications').timeBased().everyMinutes(5).create();
  form.setPublished(true);
  form.setAcceptingResponses(true);
  console.log('문의 폼: ' + form.getPublishedUrl());
  console.log('관리 시트: ' + ss.getUrl());
  console.log('폼 편집: ' + form.getEditUrl());
}

function responseSheet() {
  const p = PropertiesService.getScriptProperties();
  return SpreadsheetApp.openById(p.getProperty('SHEET_ID'))
    .getSheetById(Number(p.getProperty('RESPONSE_SHEET_ID')));
}

function onInquirySubmit(e) {
  if (!e || !e.range) throw new Error('실제 폼 제출로 실행되는 함수입니다.');
  if (e.range.getSheet().getSheetId() !== responseSheet().getSheetId()) return;
  processRow(e.range.getRow());
}

function processRow(row) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);
  try {
    const sheet = responseSheet();
    const values = sheet.getRange(row, 1, 1, 12).getValues()[0];
    if (!values[0] || values[9] === '전송 완료') return;
    if (!values[7]) {
      values[7] = 'DJ-' + Utilities.formatDate(new Date(values[0]), 'Asia/Seoul', 'yyyyMMdd') + '-' + Utilities.getUuid().slice(0, 8);
      sheet.getRange(row, 8).setValue(values[7]);
    }
    if (!values[8]) sheet.getRange(row, 9).setValue('접수');
    const webhook = PropertiesService.getScriptProperties().getProperty('DISCORD_WEBHOOK_URL');
    if (!webhook) { sheet.getRange(row, 10).setValue('전송 대기'); return; }
    if (!webhook.startsWith('https://discord.com/api/webhooks/')) throw new Error('웹훅 주소 형식을 확인하세요.');
    const message = {
      username: '디어졸리 문의 알림',
      allowed_mentions: { parse: [] },
      embeds: [{
        title: '새 문의 · ' + values[7],
        url: sheet.getParent().getUrl() + '#gid=' + sheet.getSheetId() + '&range=A' + row + ':L' + row,
        color: 7282743,
        description: String(values[5]).slice(0, 3000),
        fields: [
          { name: '답변받을 메일', value: String(values[1]).slice(0, 250) || '-', inline: true },
          { name: '닉네임', value: String(values[2]).slice(0, 100) || '-', inline: true },
          { name: '문의 종류', value: String(values[3]).slice(0, 100) || '-', inline: true },
          { name: '핸드폰 기종', value: String(values[4]).slice(0, 150) || '-', inline: true },
        ],
        timestamp: new Date(values[0]).toISOString(),
      }],
    };
    const response = UrlFetchApp.fetch(webhook + '?wait=true', {
      method: 'post', contentType: 'application/json',
      payload: JSON.stringify(message), muteHttpExceptions: true,
    });
    if (response.getResponseCode() >= 200 && response.getResponseCode() < 300) {
      PropertiesService.getScriptProperties().setProperty('MSG_' + values[7], JSON.parse(response.getContentText()).id);
      sheet.getRange(row, 10, 1, 2).setValues([['전송 완료', new Date()]]);
    } else {
      sheet.getRange(row, 10).setValue('재시도 필요');
    }
  } catch (_) {
    responseSheet().getRange(row, 10).setValue('재시도 필요');
    throw new Error('문의 알림 전송 실패. 웹훅 설정과 Discord 채널을 확인하세요.');
  } finally {
    lock.releaseLock();
  }
}

function retryNotifications() {
  const sheet = responseSheet();
  if (sheet.getLastRow() < 2) return;
  const values = sheet.getRange(2, 1, sheet.getLastRow() - 1, 12).getValues();
  let count = 0;
  for (let i = 0; i < values.length && count < 10; i++) {
    if (values[i][0] && values[i][9] !== '전송 완료') {
      try { processRow(i + 2); } catch (_) {}
      count++;
    }
  }
}
