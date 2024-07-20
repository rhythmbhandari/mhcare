String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

String getFirstCharacter(String input) {
  if (input.isEmpty) {
    return '';
  }
  return input[0];
}
