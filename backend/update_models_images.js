const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const mongoose = require('mongoose');
const Model = require('./models/Model');
const Issue = require('./models/Issue');
const connectDB = require('./config/db');

// Connect to Database
connectDB();

const updateModelImages = async () => {
    try {
        console.log('Fetching all issues from database...');
        const allIssues = await Issue.find({});
        if (allIssues.length === 0) {
            console.log('No issues found. Please run seed_issues.js first.');
            process.exit(1);
        }

        // Create a map of Issue Name -> Image URL & Other details
        const issueMap = {};
        allIssues.forEach(issue => {
            issueMap[issue.name] = issue.imageUrl;
            // Also map loose matches if needed? 
            // The app does partial matching, but DB should be consistent.
            // Map "Front Camera" -> url, "Main Speaker" -> url, "Screen" -> url
        });

        console.log(`Found ${allIssues.length} issues in Global Issue Collection.`);

        console.log('Updating all Models...');
        const models = await Model.find({});
        console.log(`Found ${models.length} models.`);

        for (const model of models) {
            let modelUpdated = false;

            // 1. Update Existing Repair Prices with Images
            for (const repairItem of model.repairPrices) {
                // If the repair item has a name that matches a global issue
                const globalIssueUrl = issueMap[repairItem.issueName];

                if (globalIssueUrl) {
                    // Update image URL
                    if (repairItem.imageUrl !== globalIssueUrl) {
                        repairItem.imageUrl = globalIssueUrl;
                        modelUpdated = true;
                    }
                }
            }

            // 2. Add Missing Critical Issues (Front Camera, Main Speaker) if not present
            // We only add if they map to our new mandatory set, to avoid bloating with every single issue?
            // The user said "ADD THESE IN REPAIRPRICES IN EACH RELATED ISSUES".
            // "THESE" refers to Front Camera and Speaker.

            const newMandatoryIssues = ['Front Camera', 'Main Speaker'];

            for (const newIssueName of newMandatoryIssues) {
                const globalIssueUrl = issueMap[newIssueName];
                if (!globalIssueUrl) {
                    console.log(`Warning: Global Issue '${newIssueName}' not found in DB.`);
                    continue;
                }

                // Check if model already has this issue
                const exists = model.repairPrices.some(rp => rp.issueName === newIssueName);
                if (!exists) {
                    // Find generic price from Issue collection or default
                    const genericIssue = allIssues.find(i => i.name === newIssueName);
                    const basePrice = genericIssue ? parseInt(genericIssue.base_price) : 999;

                    model.repairPrices.push({
                        issueName: newIssueName,
                        price: basePrice, // Use base price
                        originalPrice: Math.round(basePrice * 1.2), // Mock original price
                        discount: '20% OFF',
                        imageUrl: globalIssueUrl
                    });
                    modelUpdated = true;
                    console.log(`> Added '${newIssueName}' to ${model.name}`);
                }
            }

            if (modelUpdated) {
                await model.save();
                // console.log(`Updated model: ${model.name}`);
            }
        }

        console.log('All models updated with issue images and new required issues.');
        process.exit(0);

    } catch (error) {
        console.error('Error updating model images:', error);
        process.exit(1);
    }
};

// Wait for DB connection if needed (connectDB is async but usually buffers)
setTimeout(updateModelImages, 2000);
