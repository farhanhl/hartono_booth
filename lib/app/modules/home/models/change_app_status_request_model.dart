class ChangeAppStatusRequest {
  String? deviceId;
  int? status;

  ChangeAppStatusRequest({
    this.deviceId,
    this.status,
  });

  ChangeAppStatusRequest.fromJson(Map<Object?, dynamic> json) {
    deviceId = json['device_id'];
    status = json['status'];
  }

  Map<Object?, dynamic> toJson() {
    final data = <Object?, dynamic>{};
    data['device_id'] = deviceId;
    data['status'] = status;
    return data;
  }
}
