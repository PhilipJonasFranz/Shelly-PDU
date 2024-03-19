bool isSwitchCritical(Map<String, dynamic> switch0) {
  return (switch0["priority"] ?? "normal") == "critical";
}

bool isSwitchImportant(Map<String, dynamic> switch0) {
  return (switch0["priority"] ?? "normal") == "important";
}
