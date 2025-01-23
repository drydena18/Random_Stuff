function updateCalendar() {
  const currentYear = new Date().getFullYear();
  const calendarSheetName = `Calendar_${currentYear}`;
  const targetSheets = ["Monday_Tracker", "Tuesday_Tracker", "Wednesday_Tracker", "Thursday_Tracker", "Friday_Tracker"];
  const didGoColour = "#00FF00"; // Green
  const blankCellColour = "#000000"; // Black

  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet(); // Get active spreadsheet
  const calendarSheet = getOrCreateSheet(spreadsheet, calendarSheetName);

  // Clear and create the calendar layout
  calendarSheet.clear();
  createCalendarLayout(calendarSheet, currentYear);

  // Extract valid dates from target sheets
  const dateStatuses = {};
  targetSheets.forEach(sheetName => {
    const sheet = spreadsheet.getSheetByName(sheetName);
    if (!sheet) {
      Logger.log(`Sheet "${sheetName}" not found. Skipping.`);
      return;
    }

    const dataRange = sheet.getRange(1, 1, sheet.getLastRow(), 1); // Assume dates are in column A
    const values = dataRange.getValues();

    values.forEach(row => {
      const cell = row[0];
      if (isValidDate(cell) && isSameYear(cell, currentYear)) {
        const formattedDate = Utilities.formatDate(new Date(cell), Session.getScriptTimeZone(), "MM/dd/yyyy");
        dateStatuses[formattedDate] = true;
      }
    });
  });

  // Apply conditional formatting
  const updatedRules = [];

  // Add formatting rules for the detected dates
  Object.keys(dateStatuses).forEach(date => {
    updatedRules.push(
      SpreadsheetApp.newConditionalFormatRule()
        .whenFormulaSatisfied(`=TEXT(A1, "MM/dd/yyyy")="${date}"`)
        .setBackground(didGoColour)
        .setRanges([calendarSheet.getDataRange()])
        .build()
    );
  });

  // Add a rule for blank cells
  updatedRules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("")
      .setBackground(blankCellColour)
      .setRanges([calendarSheet.getDataRange()])
      .build()
  );

  calendarSheet.setConditionalFormatRules(updatedRules);
}

function createCalendarLayout(sheet, year) {
  const headerRow = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  sheet.getRange(1, 1, 1, 7).setValues([headerRow]);

  let row = 2;
  for (let month = 0; month < 12; month++) {
    const startDate = new Date(year, month, 1);
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    // Add a header for the month
    sheet.getRange(row, 1, 1, 7).merge().setValue(startDate.toLocaleString("default", { month: "long" }));
    row++;

    let col = 1;
    const firstDayOfWeek = startDate.getDay();
    for (let i = 0; i < firstDayOfWeek; i++) {
      sheet.getRange(row, col).setValue("");
      col++;
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const currentDate = new Date(year, month, day);
      const cell = sheet.getRange(row, col);
      cell.setValue(Utilities.formatDate(currentDate, Session.getScriptTimeZone(), "MM/dd/yyyy"));
      cell.setNumberFormat("MM/dd/yyyy");

      col++;
      if (col > 7) {
        col = 1;
        row++;
      }
    }
    row++;
  }
}

function isValidDate(value) {
  return Object.prototype.toString.call(value) === "[object Date]" && !isNaN(value)
    || typeof value === "string" && !isNaN(Date.parse(value));
}

function isSameYear(dateValue, year) {
  const date = new Date(dateValue);
  return date.getFullYear() === year;
}

function getOrCreateSheet(spreadsheet, sheetName) {
  let sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(sheetName);
  } else {
    sheet.clear();
  }
  return sheet;
}
