const XLSX = require('xlsx');
const path = require('path');

const filePath = '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/REALME ALL MODELS.xlsx';

try {
    const workbook = XLSX.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });

    data.slice(5, 20).forEach((row, index) => {
        console.log(`Row ${index + 5}:`, row);
    });
} catch (error) {
    console.error("Error reading file:", error);
}
