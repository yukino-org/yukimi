const { promises: fs } = require("fs");
const path = require("path");

const getVersion = async () => {
    const pubspec = (
        await fs.readFile(path.join(__dirname, "../../pubspec.yaml"))
    ).toString();

    return pubspec.match(/version: ([\w-.]+)/)[1];
};

module.exports = { getVersion };
