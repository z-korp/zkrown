// Update the hexadecimal color values in the customColors object to make them less vibrant
export const customColors = {
  customRed: {
    100: "#FFCCCC",
    200: "#FFB2B2",
    300: "#FF9999",
    400: "#FF8080",
    500: "#FF6666",
    600: "#FF4D4D",
    700: "#FF3333",
    800: "#FF1A1A",
    900: "#FF0000",
  },
  customBlue: {
    100: "#99CCFF",
    200: "#80BFFF",
    300: "#66B3FF",
    400: "#4D9DFF",
    500: "#3380FF",
    600: "#1A66FF",
    700: "#004DFF",
    800: "#0033CC",
    900: "#001A99",
  },
  customGreen: {
    100: "#ecffe6",
    200: "#d5ffd1",
    300: "#beffbc",
    400: "#a8ffa6",
    500: "#91ff91",
    600: "#7aff7a",
    700: "#63ff63",
    800: "#4cff4c",
    900: "#36ff36",
  },
  customYellow: {
    100: "#ffffcc",
    200: "#ffffb2",
    300: "#ffff99",
    400: "#ffff80",
    500: "#ffff66",
    600: "#ffff4d",
    700: "#ffff33",
    800: "#ffff1a",
    900: "#ffff00",
  },
  customPurple: {
    100: "#D9CCFF",
    200: "#C2B2FF",
    300: "#AB99FF",
    400: "#947FFF",
    500: "#7A66FF",
    600: "#634DFF",
    700: "#4C33FF",
    800: "#351AFF",
    900: "#1E00FF",
  },
  customTeal: {
    100: "#80CCCC",
    200: "#66B2B2",
    300: "#4D9999",
    400: "#338080",
    500: "#1A6666",
    600: "#004D4D",
    700: "#003333",
    800: "#001A1A",
    900: "#000000",
  },
  customPink: {
    100: "#FFC4E1",
    200: "#FFC0E1",
    300: "#FF99B5",
    400: "#FF83A0",
    500: "#FF6D8A",
    600: "#FF5774",
    700: "#FF415F",
    800: "#FF2B49",
    900: "#FF1533",
  },
  customOrange: {
    100: "#FFDFBF",
    200: "#FFCC99",
    300: "#FFB380",
    400: "#FF9966",
    500: "#FF804D",
    600: "#FF6633",
    700: "#FF4D1A",
    800: "#FF3300",
    900: "#E61A00",
  },

  customCian: {
    100: "#B3FFFF",
    200: "#99FFFF",
    300: "#80FFFF",
    400: "#66FFFF",
    500: "#4DFFFF",
    600: "#33FFFF",
    700: "#1AFFFF",
    800: "#00FFFF",
    900: "#00CCCC",
  },
};

export const colorTilePlayer = [
  "#fff", // 'none'
  ...Object.values(customColors).map((colorObj) => colorObj[200]),
];

export const colorTilePlayerHighlight = [
  "#fff", // 'none'
  ...Object.values(customColors).map((colorObj) => colorObj[500]),
];

export const colorTilePlayerDark = [
  "#fff", // 'none'
  ...Object.values(customColors).map((colorObj) => colorObj[800]),
];
