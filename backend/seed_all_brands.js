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

// Map file names to Brand Names and Icon/Image
const files = [
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/apples mobile models.xlsx',
        brandName: 'Apple',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/One Plus All Models.xlsx',
        brandName: 'OnePlus',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2b/OnePlus_Logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/SAMSUNG  GALAXY MODELS.xlsx',
        brandName: 'Samsung',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/VIVO MODELS.xlsx',
        brandName: 'Vivo',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Vivo_mobile_logo.png/1200px-Vivo_mobile_logo.png'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/xiaomi mobiles models.xlsx',
        brandName: 'Xiaomi',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/ae/Xiaomi_logo_2021.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/REALME ALL MODELS.xlsx',
        brandName: 'Realme',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Realme_logo.png/1200px-Realme_logo.png'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/google all models.xlsx',
        brandName: 'Google',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/honor all models.xlsx',
        brandName: 'Honor',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Honor_Logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/MOTO ALL MODELS.xlsx',
        brandName: 'Motorola',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Motorola_new_logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/NOKIA ALL MODELS.xlsx',
        brandName: 'Nokia',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/02/Nokia_wordmark.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/Oppo All Models.xlsx',
        brandName: 'Oppo',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b8/OPPO_Logo.svg'
    },
    {
        file: '/Users/yogeshthaku/Desktop/Ziyonstar/ziyonstar/ASUS ALL MODELS.xlsx',
        brandName: 'Asus',
        icon: 'smartphone',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2e/ASUS_Logo.svg'
    }
];

const standardizeIssueName = (rawName) => {
    if (!rawName) return null;
    const lower = rawName.toString().toLowerCase().trim();

    // Display
    if (lower.includes('screen') || lower.includes('glass') || lower.includes('folder') || lower.includes('display') || lower.includes('lcd') || lower.includes('combo') || lower.includes('touch')) return 'Screen';

    // Battery
    if (lower.includes('battery')) return 'Battery';

    // Receiver (Handle typos like 'recevier')
    if (lower.includes('receiver') || lower.includes('recevier') || lower.includes('earpiece')) return 'Receiver';

    // Charging
    if (lower.includes('charging') || lower.includes('connector') || lower.includes('sub board') || lower.includes('usb')) return 'Charging Jack';

    // Mic
    if (lower.includes('mic')) return 'Mic';

    // Speaker
    if (lower.includes('speaker') || lower.includes('ringer') || lower.includes('buzzer')) return 'Speaker';

    // Cameras
    if (lower.includes('front camera') || lower.includes('f cam') || lower.includes('f.cam') || lower.includes('selfie')) return 'Front Camera';
    if (lower.includes('back camera') || lower.includes('b cam') || lower.includes('b.cam') || lower.includes('rear') || lower.includes('main cam')) return 'Back Camera';

    // Aux
    if (lower.includes('aux') || lower.includes('audio') || lower.includes('headphone')) return 'Aux Jack';

    // Security
    if (lower.includes('finger') || lower.includes('biometric')) return 'Fingerprint';
    if (lower.includes('face') && lower.includes('id')) return 'Face/Touch ID';

    // Others
    if (lower.includes('sensor')) return 'Sensors';
    if (lower.includes('motherboard') || lower.includes('main board')) return 'Motherboard';
    if (lower.includes('water') || lower.includes('liquid')) return 'Water Damage';
    if (lower.includes('software') || lower.includes('flash')) return 'Software';
    if (lower.includes('back glass') || lower.includes('back door') || lower.includes('back panel') || lower.includes('battery cover')) return 'Back Glass';

    return null;
};

const getIssueImage = (issueName) => {
    const mapping = {
        'Screen': 'assets/images/issues/issue_screen.png',
        'Battery': 'assets/images/issues/issue_battery.png',
        'Receiver': 'assets/images/issues/issue_mic.png', // Using mic for receiver
        'Charging Jack': 'assets/images/issues/issue_charging.png',
        'Mic': 'assets/images/issues/issue_mic.png',
        'Speaker': 'assets/images/issues/issue_speaker.png',
        'Front Camera': 'assets/images/issues/issue_camera.png',
        'Back Camera': 'assets/images/issues/issue_camera.png',
        'Aux Jack': 'assets/images/issues/issue_charging.png', // Using charging for aux
        'Fingerprint': 'assets/images/issues/issue_faceid.png', // Using faceid for fingerprint
        'Face/Touch ID': 'assets/images/issues/issue_faceid.png',
        'Sensors': 'assets/images/issues/issue_sensors.png',
        'Motherboard': 'assets/images/issues/issue_motherboard.png',
        'Water Damage': 'assets/images/issues/issue_water.png',
        'Software': 'assets/images/issues/issue_software.png',
        'Back Glass': 'assets/images/issues/issue_backglass.png',
    };
    return mapping[issueName] || null;
};

const processFile = async (fileConfig) => {
    console.log(`\nProcessing ${fileConfig.brandName}...`);

    // 1. Find or Create Brand
    let brand = await Brand.findOne({ title: { $regex: new RegExp(`^${fileConfig.brandName}$`, 'i') } });
    if (!brand) {
        brand = await Brand.create({
            title: fileConfig.brandName,
            description: `${fileConfig.brandName} Repair Services`,
            icon: fileConfig.icon,
            imageUrl: fileConfig.imageUrl
        });
        console.log(`+ Created Brand: ${fileConfig.brandName}`);
    } else {
        console.log(`* Found Brand: ${brand.title}`);
    }

    // 2. Read Excel
    try {
        const workbook = XLSX.readFile(fileConfig.file);
        const sheet = workbook.Sheets[workbook.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(sheet, { header: 1 });

        let modelsToInsert = [];
        let currentModel = null;

        // Keywords to skip lines that are headers or junk
        const exclusionKeywords = ['price', 'discount', 'final', 'repair', 'services', 'model'];

        for (let i = 0; i < data.length; i++) {
            const row = data[i];
            if (!row || row.length === 0) continue;

            const txt = row[0] ? row[0].toString().trim() : '';
            if (!txt) continue;

            // TYPO FIX: GPPGLE -> GOOGLE
            let cleanName = txt;
            if (cleanName.includes('GPPGLE')) {
                cleanName = cleanName.replace('GPPGLE', 'GOOGLE');
            }

            const lowerTxt = cleanName.toLowerCase();

            // Check if this row is an issue/part
            const issueName = standardizeIssueName(lowerTxt);

            if (issueName) {
                // It IS a part row (e.g. "Screen", "Battery")
                if (currentModel) {

                    let originalPrice, discount, finalPrice;

                    // Data Structure Handling
                    if (fileConfig.brandName === 'Google' || fileConfig.brandName === 'Motorola') {
                        // Google & Moto have 2 empty columns: [ 'screen', null, null, 32999, 0.35, 21449.35 ]
                        originalPrice = row[3];
                        discount = row[4];
                        finalPrice = row[5];
                    } else {
                        // Standard: [ 'screen', null, 24500, 0.4, 14700 ]
                        originalPrice = row[2];
                        discount = row[3];
                        finalPrice = row[4];
                    }

                    // Fallback: If shifted/different, try to guess?
                    // Some files might be [ 'screen', 6000, 3120 ]?
                    // But standard seems to be the above.

                    // If finalPrice is missing but row[2] looks like a price?
                    // Actually, let's trust the observed structure first.

                    if (finalPrice) {
                        const numPrice = Math.round(parseFloat(finalPrice));
                        const numOriginal = Math.round(parseFloat(originalPrice));

                        // Format Discount
                        let discountStr = null;
                        if (discount) {
                            if (typeof discount === 'number') {
                                if (discount < 1) {
                                    // e.g. 0.48 -> 48%
                                    discountStr = Math.round(discount * 100) + '%';
                                } else {
                                    // e.g. 25 -> 25% (assume whole number percentage)
                                    discountStr = Math.round(discount) + '%';
                                }
                            } else {
                                // e.g. "48%" or "48"
                                discountStr = discount.toString();
                                if (!discountStr.includes('%')) discountStr += '%';
                            }
                        }

                        if (!isNaN(numPrice)) {
                            // Check if duplicate issue already exists for this model
                            const exists = currentModel.repairPrices.find(p => p.issueName === issueName);
                            if (!exists) {
                                currentModel.repairPrices.push({
                                    issueName: issueName,
                                    price: numPrice,
                                    originalPrice: !isNaN(numOriginal) ? numOriginal : null,
                                    discount: discountStr,
                                    imageUrl: getIssueImage(issueName)
                                });
                            }
                        }
                    }
                }
            } else {
                // Not a part row. Is it a Model Name?

                // Check if it's a junk header row
                if (exclusionKeywords.some(k => lowerTxt.includes(k))) continue;

                // Checks for brand name in text to confirm it's a heading? 
                // Actually, in the Realme file, the model name was just the text.
                // Assuming any non-issue, non-excluded text is a Model Name.


                // Calculate Price if currentModel exists
                if (currentModel) {
                    let basePrice = '0';
                    const screenPrice = currentModel.repairPrices.find(p => p.issueName === 'Screen');
                    if (screenPrice) {
                        basePrice = screenPrice.price.toString();
                    } else if (currentModel.repairPrices.length > 0) {
                        basePrice = currentModel.repairPrices[0].price.toString();
                    }

                    currentModel.price = basePrice;
                    modelsToInsert.push(currentModel);
                    if (fileConfig.brandName === 'Samsung') {
                        console.log(`--- Parsed Model: ${currentModel.name} ---`);
                        console.log(currentModel.repairPrices);
                    }
                }

                currentModel = {
                    name: cleanName,
                    repairPrices: [],
                    price: '0'
                };
                if (fileConfig.brandName === 'Google') {
                    console.log(`[Google] Started Model: ${cleanName}`);
                }
            }
        }
        // Push last one
        if (currentModel) {
            let basePrice = '0';
            const screenPrice = currentModel.repairPrices.find(p => p.issueName === 'Screen');
            if (screenPrice) {
                basePrice = screenPrice.price.toString();
            } else if (currentModel.repairPrices.length > 0) {
                basePrice = currentModel.repairPrices[0].price.toString();
            }
            currentModel.price = basePrice;
            modelsToInsert.push(currentModel);
        }

        console.log(`Identified ${modelsToInsert.length} models for ${fileConfig.brandName}.`);

        // 3. Upsert Models
        for (const m of modelsToInsert) {
            if (m.repairPrices.length === 0) continue; // Skip models with no prices found

            await Model.findOneAndUpdate(
                { brandId: brand._id, name: m.name },
                {
                    brandId: brand._id,
                    name: m.name,
                    price: m.price || '0', // Ensure String
                    repairPrices: m.repairPrices
                },
                { upsert: true, new: true }
            );
            // console.log(`> Upserted: ${m.name}`);
        }
        console.log(`Finished ${fileConfig.brandName}`);

    } catch (e) {
        console.error(`Error processing ${fileConfig.brandName}:`, e.message);
    }
};

const run = async () => {
    await connectDB();
    for (const f of files) {
        await processFile(f);
    }
    console.log('\n--- ALL BRANDS SEEDED ---');
    process.exit();
};

run();
