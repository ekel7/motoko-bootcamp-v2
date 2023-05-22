import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Order "mo:base/Order";


actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Order = Order.Order;


  stable var messageIdCounter : Nat = 0;
  var wall = HashMap.HashMap<Text, Message>(0, Text.equal, Text.hash);


  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let Id : Nat = messageIdCounter;
    messageIdCounter += 1;

    var message : Message = {
      vote = 0;
      content = c;
      creator = caller;
    };

    var textToNat = Nat.toText(Id);
    wall.put(textToNat, message);
    return Id;
  };

  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let messageContent = wall.get(Nat.toText(messageId));

    switch (messageContent) {
      case (null) {
        return #err("The requested message not found");
      };
      case (?messageContent) {
        return #ok(messageContent);
      };
    };
  };

  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {

    let messageContent = wall.get(Nat.toText(messageId));

    switch (messageContent) {
      case (null) {
        return #err("Message does not exist!");
      };
      case (?messageContent) {
        let updatedMesssage : Message = {
          vote = messageContent.vote;
          content = c;
          creator = messageContent.creator;
        };
        wall.put(Nat.toText(messageId), updatedMesssage);
        return #ok();
      };
    };
  };
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let messageContent = wall.get(Nat.toText(messageId));

    switch (messageContent) {
      case (null) {
        return #err("Message does not exist!");
      };
      case (?messageContent) {
        ignore wall.remove(Nat.toText(messageId));
        return #ok();
      };
    };
    return #ok();
  };


  public shared func upVote(messageId : Nat) : async Result.Result<(), Text> {
  
    let messageContent = wall.get(Nat.toText(messageId));

    switch (messageContent) {
      case (null) {
        return #err("Message does not exist!");
      };
      case (?messageContent) {
        let updatedMesssage : Message = {
          vote = messageContent.vote +1;
          content = messageContent.content;
          creator = messageContent.creator;
        };
        wall.put(Nat.toText(messageId), updatedMesssage);
        return #ok();
      };
    };  

  };



  public shared func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let messageContent = wall.get(Nat.toText(messageId));

    switch (messageContent) {
      case (null) {
        return #err("Message does not exist!");
      };
      case (?messageContent) {
        let updatedMesssage : Message = {
          vote = messageContent.vote -1;
          content = messageContent.content;
          creator = messageContent.creator;
        };
        wall.put(Nat.toText(messageId), updatedMesssage);
        return #ok();
      };
    }; 
  };

  public query func getAllMessages() : async [Message] {
    let messagesBuffer = Buffer.Buffer<Message>(0);

    var recorrer = Iter.toArray(wall.vals());
    return recorrer;
    /*
    for (messages in wall.vals()) {
      messagesBuffer.add(messages);
    };
    return Buffer.toArray<Message>(messagesBuffer);
    */
  };

  public func getAllMessagesRanked() : async [Message] {
    let messages = Iter.toArray(wall.vals());
    let rank = Array.sort<Message>(messages, func(m1: Message, m2 : Message) : Order{
        if(m1.vote > m2.vote){
          #greater;
        } else if (m1.vote < m2.vote){
          #less;
        } else {
          #equal;
        }
    });
    return rank;
  };

};