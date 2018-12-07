export default function hexToRgba(hex, opacity = 1) {
  const cleanHex = hex.replace('#', '');
  const rgb =
    cleanHex.length === 3
      ? cleanHex.split('').map(val => val + val)
      : cleanHex.match(/[\da-f]{2}/gi);
  const [r, g, b] = rgb.map(val => parseInt(val, 16));

  return `rgb(${r}, ${g}, ${b}, ${opacity})`;
}
