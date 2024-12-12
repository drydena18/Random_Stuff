function updateCalendar() {
  const currentYear = new Date().getFullYear();
  const sheetName = `Calendar_${currentYear}`; // Create a year-specific calendar sheet
  const targetSheets = ["Chest_Tracker", "Back_Tracker", "Arms_Shoulders_Tracker", "Chest_Back_SS_Tracker", "Arms_Core_Tracker"];
  const didGoColour = "#00FF00"; // Green
  const blankCellColour = "#000000"; // Black

  const calendarSheet = getOrCreateSheet(sheetName);
  
  // Clear existing content and create a new calendar layout
  calendarSheet.clear();
  createCalendarLayout(calendarSheet, currentYear);

  // Extract all valid dates from targetSheets (for the current year only)
  const dateStatuses = {};
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();

  targetSheets.forEach(sheetName => {
    const sheet = spreadsheet.getSheetByName(sheetName);
    if (!sheet) return;

    const dataRange = sheet.getRange(1, 1, sheet.getLastRow(), 1); // Column A
    const values = dataRange.getValues();

    // Log data from the target sheet
    console.log(`Checking sheet: ${sheetName}`);
    console.log(values);

    values.forEach(row => {
      const cell = row[0];
      if (isValidDate(cell) && isSameYear(cell, currentYear)) {
        const formattedDate = Utilities.formatDate(new Date(cell), Session.getScriptTimeZone(), "MM/dd/yyyy");
        dateStatuses[formattedDate] = true;
      }
    });
  });

  // Debugging: Log detected dates
  console.log("Detected Dates:", Object.keys(dateStatuses));

  // Get current rules
  const existingRules = calendarSheet.getConditionalFormatRules();
  let updatedRules = existingRules.filter(rule => {
    const condition = rule.getBooleanCondition();
    if (condition) {
      const criteria = condition.getCriteriaValues();
      // Check if it's a text-based condition with date format (e.g. MM/dd/yyyy)
      if (criteria.length > 0 && typeof criteria[0] === 'string' && criteria[0].match(/\d{2}\/\d{2}\/\d{4}/)) {
        return false; // Remove this rule if it's based on a date in MM/dd/yyyy format
      }
    }
    return true;
  });

  // Apply new conditional formatting rules for the detected dates
  Object.keys(dateStatuses).forEach(date => {
    updatedRules.push(
      SpreadsheetApp.newConditionalFormatRule()
        .whenFormulaSatisfied('=TEXT(A1, "MM/dd/yyyy")="' + date + '"') // Use formula to compare dates
        .setBackground(didGoColour)
        .setRanges([calendarSheet.getDataRange()])
        .build()
    );
  });

  // Add a default rule for blank cells
  updatedRules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo("")
      .setBackground(blankCellColour)
      .setRanges([calendarSheet.getDataRange()])
      .build()
  );

  // Apply the updated rules to the calendar sheet
  calendarSheet.setConditionalFormatRules(updatedRules);
}

function createCalendarLayout(sheet, year) {
  const headerRow = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  sheet.getRange(1, 1, 1, 7).setValues([headerRow]);

  let row = 2;
  for (let month = 0; month < 12; month++) {
    const startDate = new Date(year, month, 1);
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    // Add a header row for the month name (merged across columns A to G)
    sheet.getRange(row, 1, 1, 7).merge().setValue(startDate.toLocaleString('default', { month: 'long' }));
    row++;

    let col = 1;
    const firstDayOfWeek = startDate.getDay();
    // Add blank spaces for days before the start of the month
    for (let i = 0; i < firstDayOfWeek; i++) {
      sheet.getRange(row, col).setValue("");
      col++;
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const currentDate = new Date(year, month, day);
      const cell = sheet.getRange(row, col);
      cell.setValue(Utilities.formatDate(currentDate, Session.getScriptTimeZone(), "MM/dd/yyyy"));
      cell.setNumberFormat("MM/dd/yyyy"); // Ensure proper date formatting

      col++;
      if (col > 7) { // Move to the next row after Saturday
        col = 1;
        row++;
      }
    }

    // Move to the next row after finishing the month
    row++;
  }
}

function isValidDate(value) {
  // Check if value is a valid date object or a string that can be converted to a date
  if (Object.prototype.toString.call(value) === '[object Date]') {
    return !isNaN(value);
  } else if (typeof value === "string") {
    const date = new Date(value);
    return !isNaN(date);
  }
  return false;
}

function isSameYear(dateValue, year) {
  const date = new Date(dateValue);
  return date.getFullYear() === year;
}

function getOrCreateSheet(name) {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = spreadsheet.getSheetByName(name);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(name);
  } else {
    sheet.clear(); // Clear the existing sheet if it's already there
  }
  return sheet;
}
