const puppeteer = require('puppeteer');
(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('http://localhost:62613/', {waitUntil: 'networkidle2'});
    console.log('Current URL:', page.url());
    
    // click on repair link? Let's check if we can wait for flutter to load
    await new Promise(r => setTimeout(r, 5000));
    console.log('URL after wait:', page.url());
    
    await browser.close();
})();
