const { promises: fs } = require("fs");
const { platform } = require("os");
const path = require("path");

const getExecutableName = async () => {
    const { APP_NAME, OUTPUT_EXE_DIR } = process.env;

    let suffix = "";
    switch (platform()) {
        case "win32":
            suffix = "-windows.exe";
            break;

        case "linux":
            suffix = "-linux";
            break;

        case "darwin":
            suffix = "-macos";
            break;

        default:
            throw Error("Unsupported platform");
    }

    await fs.mkdir(OUTPUT_EXE_DIR, { recursive: true });
    return path.join(OUTPUT_EXE_DIR, `${APP_NAME}${suffix}`);
};

module.exports = { getExecutableName };
