class OnlineUsersResponse {
  OnlineUsersResponse({
    required this.message,
    required this.users,
    required this.userIds,
    required this.bots,
    required this.totalCount,
  }) : hiddenCount = totalCount - users.length;
  final String message;
  final List<String> users;
  final List<String> userIds;
  final List<String> bots;
  final int hiddenCount, totalCount;
}
