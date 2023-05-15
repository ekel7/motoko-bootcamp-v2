import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import Hash "mo:base/Hash";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;
  type Order = Order.Order;

  stable var messageIdCount : Nat = 0;
  //Stable variable so it can survive upgrades

  let wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared({ caller }) func writeMessage(c : Content) : async Nat {
    //caller represents the creator's data
    //1. prepare data
    let post : Message = {
      vote = 0;
      creator = caller;
      content = c;
    };

    //2. add post
    wall.put(messageIdCount, post);

    messageIdCount += 1;

    //3. return confirmation - Is it even necessary? seems not to be
    return messageIdCount;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Error trying to obtain message to edit, check if the ID is correct");
      };
      case (?message) {
        return #ok(message);
      };
    };
  };

  // Update the content for a specific message by ID
  public shared({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Error trying to obtain message to edit, check if the ID is correct");
      };
      case (?message) {
        let newMessage : Message = {
          content = c;
          vote = message.vote;
          creator = message.creator;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok();
      };
    };
  };

  // Delete a specific message by ID
  public shared({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    if ((messageId <= 0) and (messageId < wall.size())) {
      wall.delete(messageId);
      return #ok();
    } else {
      return #err("ID does not exist");
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Error trying to obtain message, check if the ID is correct");
      };

      case (?message) {
        let newMessage : Message = {
          content = message.content;
          vote = message.vote +1;
          creator = message.creator;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok();
      };
    };
  };
  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) {
        return #err("Error trying to obtain message, check if the ID is correct");
      };

      case (?message) {
        let newMessage : Message = {
          content = message.content;
          vote = message.vote +1;
          creator = message.creator;
        };
        ignore wall.replace(messageId, newMessage);
        return #ok();
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let postsArray : [Message] = Iter.toArray(wall.vals());
    //converts the hashmap to array so it can be returned
    return postsArray;
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    func comparePosts(p1 : Message, p2 : Message) : Order {
      if (p1.vote == p2.vote) {
        return #equal;
      };
      if (p1.vote > p2.vote) {
        return #less;
      };
      return #greater;
    };

    let array : [Message] = Iter.toArray(wall.vals());
    return Array.sort<Message>(array, comparePosts);
  };
};
