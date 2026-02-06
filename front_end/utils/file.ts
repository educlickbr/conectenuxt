export const generateUuidFileName = (originalName: string): string => {
    // Get extension or empty string if none
    const parts = originalName.split(".");
    const extension = parts.length > 1 ? parts.pop() : "";
    
    // Generate UUID v4-like string
    const uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(
        /[xy]/g,
        function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === "x" ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        },
    );

    // Return UUID + extension (if exists)
    return extension ? `${uuid}.${extension}` : uuid;
};
