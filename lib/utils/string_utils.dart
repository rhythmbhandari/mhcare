// Capitalizes the first letter of the given input string.
String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

// Returns the first character of the given input string.
String getFirstCharacter(String input) {
  if (input.isEmpty) {
    return '';
  }
  return input[0];
}
