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
    let realme = await Brand.findOne({ title: { $regex: /^realme$/i } });
    if (!realme) {
        realme = await Brand.create({
            title: 'Realme',
            description: 'Realme Smartphones Repair Services',
            icon: 'smartphone',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Realme_logo.svg/2560px-Realme_logo.svg.png'
        });
        console.log('Created Brand: Realme');
    }

    // 2. Read Excel
    const workbook = XLSX.readFile('/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/REALME ALL MODELS.xlsx');
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });

    let modelsToInsert = [];
    let currentModel = null;

    // Mapping from Excel text to Standardized Issue Types
    // Users might see "Screen", "Battery" in app.
    const issueMapping = {
        'screen': 'Screen',
        'glass': 'Screen',      // Treat Glass as Screen variant or separate? Assuming Screen for now or Glass
        'folder': 'Screen',
        'battery': 'Battery',
        'receiver': 'Receiver',
        'charging': 'Charging Jack',
        'charging jack': 'Charging Jack',
        'mic': 'Mic',
        'speaker': 'Speaker',
        'front camera': 'Front Camera',
        'back camera': 'Back Camera',
        'aux': 'Aux Jack',
        'aux jack': 'Aux Jack',
        'finger': 'Fingerprint',
        'sub board': 'Sub Board',
        'main flex': 'Main Flex',
        // 'copy': 'Screen Copy', // Specific variants
        // 'og': 'Screen OG'
    };

    // Keywords to ignore when looking for Model Names
    const exclusionKeywords = [
        'screen', 'battery', 'receiver', 'charging', 'mic', 'speaker',
        'front camera', 'back camera', 'aux', 'glass', 'folder',
        'sub board', 'main flex', 'finger', 'price', 'discount',
        'final price', 'copy', 'og', 'realme models', '& repairs'
    ];

    for (let i = 0; i < data.length; i++) {
        const row = data[i];
        if (!row || row.length === 0) continue;

        const txt = row[0] ? row[0].toString().trim() : '';
        if (!txt) continue;

        const lowerTxt = txt.toLowerCase();

        // Check if this row is an issue/part
        let isIssue = false;
        let matchedIssueName = null;

        for (const [key, val] of Object.entries(issueMapping)) {
            if (lowerTxt.includes(key)) {
                isIssue = true;
                matchedIssueName = val;
                break;
            }
        }

        if (isIssue) {
            // It is an issue row. extract price.
            if (currentModel) {
                // Col 4 is Final Price, Col 2 is Price. Prefer Col 4.
                let price = row[4];
                if (!price) price = row[2];

                if (price) {
                    // Try to parse number
                    const numPrice = parseFloat(price);
                    if (!isNaN(numPrice)) {
                        currentModel.repairPrices.push({
                            issueName: matchedIssueName,
                            price: numPrice
                        });
                    }
                }
            }
        } else {
            // Check if it's a header or junk
            if (exclusionKeywords.some(k => lowerTxt.includes(k))) continue;

            // Assume it's a new Model
            if (currentModel) {
                modelsToInsert.push(currentModel);
            }

            // Fix Typos in Name
            let cleanName = txt;
            if (cleanName.match(/^REA.*E/i)) {
                cleanName = cleanName.replace(/REAMNE/i, 'REALME')
                    .replace(/REAL,E/i, 'REALME')
                    .replace(/RELAME/i, 'REALME');
            }

            currentModel = {
                name: cleanName,
                repairPrices: []
            };
        }
    }
    if (currentModel) modelsToInsert.push(currentModel);

    console.log(`Identified ${modelsToInsert.length} models.`);

    // 3. Upsert into DB
    for (const m of modelsToInsert) {
        await Model.findOneAndUpdate(
            { brandId: realme._id, name: m.name },
            {
                brandId: realme._id,
                name: m.name,
                repairPrices: m.repairPrices
            },
            { upsert: true, new: true }
        );
        console.log(`> Processed: ${m.name} (${m.repairPrices.length} pricing items)`);
    }

    console.log('Seed Complete');
    process.exit();
};

seed();
