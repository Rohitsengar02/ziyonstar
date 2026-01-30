const mongoose = require('mongoose');
const XLSX = require('xlsx');
const Model = require('./models/Model');
const Brand = require('./models/Brand');
require('dotenv').config();

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');
    } catch (error) {
        console.error('DB Error', error);
        process.exit(1);
    }
};

const seed = async () => {
    await connectDB();

    // 1. Find or Create Realme Brand
    // Case insensitive header
    let realme = await Brand.findOne({ title: { $regex: /^realme$/i } });
    if (!realme) {
        realme = await Brand.create({
            title: 'Realme',
            description: 'Realme Smartphones Repair Services',
            icon: 'smartphone',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Realme_logo.svg/2560px-Realme_logo.svg.png'
        });
        console.log('Created Brand: Realme');
    } else {
        console.log('Found Brand:', realme.title);
    }

    // 2. Read Excel
    const workbook = XLSX.readFile('/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/REALME ALL MODELS.xlsx');
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });

    let modelsToInsert = [];
    let currentModel = null;

    // List of keywords that indicate a row is NOT a model name
    const exclusionKeywords = [
        'screen', 'battery', 'receiver', 'charging', 'mic', 'speaker',
        'front camera', 'back camera', 'aux', 'glass', 'folder',
        'sub board', 'main flex', 'finger', 'price', 'discount',
        'final price', 'copy', 'og', 'realme models', '& repairs'
    ];

    for (let i = 0; i < data.length; i++) {
        const row = data[i];
        if (!row || row.length === 0) continue;

        // Column 0 text
        const txt = row[0] ? row[0].toString().trim() : '';
        if (!txt) continue;

        const lowerTxt = txt.toLowerCase();

        // Check if it's an issue/pricing row
        const isIssue = exclusionKeywords.some(keyword => lowerTxt.includes(keyword));

        if (isIssue) {
            // It's an issue row. 
            // If it's a screen price, let's grab it for the current model
            if (currentModel && lowerTxt.includes('screen')) {
                // Prefer Final Price (col 4), then Base Price (col 2)
                let price = row[4];
                if (!price) price = row[2];

                if (price) {
                    currentModel.price = price.toString();
                }
            }
        } else {
            // It is likely a Model Name

            // Push the previous model if it exists
            if (currentModel) {
                modelsToInsert.push(currentModel);
            }

            // Start new model
            // Fix "REAMNE" typo if present
            let name = txt.replace(/REAMNE/i, 'REALME');

            currentModel = {
                name: name,
                price: '0' // Default
            };
        }
    }
    // Push last model
    if (currentModel) modelsToInsert.push(currentModel);

    console.log(`Identified ${modelsToInsert.length} models from Excel.`);

    // 3. Insert/Update in DB
    for (const m of modelsToInsert) {
        // Additional Typo Fixes
        let cleanName = m.name;

        // Regex to fix common typos like "REAMNE", "REAL,E", etc. assuming they start the string
        if (cleanName.match(/^REA.*E/i)) { // Very loose check for Realm...
            cleanName = cleanName.replace(/REAMNE/i, 'REALME');
            cleanName = cleanName.replace(/REAL,E/i, 'REALME');
            cleanName = cleanName.replace(/RELAME/i, 'REALME');
        }

        // Use findOneAndUpdate to UPSERT (Update if exists, Insert if not)
        // We match by Name AND BrandId
        const result = await Model.findOneAndUpdate(
            { brandId: realme._id, name: cleanName },
            {
                brandId: realme._id,
                name: cleanName,
                price: m.price
            },
            { upsert: true, new: true }
        );

        console.log(`> Processed: ${cleanName} (Price: ${m.price})`);
    }

    console.log('Seed Complete');
    process.exit();
};

seed();
