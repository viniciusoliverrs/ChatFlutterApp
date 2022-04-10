import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  Map<String, dynamic> data;
  bool mine;
  ChatMessage(this.data, this.mine, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromARGB(255, 198, 198, 198)),
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  data["senderName"],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                data["img"] != null
                    ? Image.network(
                        data["img"],
                        width: 250,
                      )
                    : Text(
                        data["text"],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
