const { promises: fs } = require("fs");
const path = require("path");
const { getVersion } = require("./version");

const generateData = async () => {
    const version = await getVersion();
    const dataDir = path.resolve(__dirname, "../../dist");

    await fs.mkdir(dataDir, { recursive: true });
    await fs.writeFile(
        path.join(dataDir, "badge-endpoint.json"),
        JSON.stringify({
            schemaVersion: 1,
            label: "version",
            message: `v${version}`,
            color: "blue",
        })
    );
    await fs.writeFile(path.join(dataDir, "version.txt"), version);

    return dataDir;
};

module.exports = { generateData };
