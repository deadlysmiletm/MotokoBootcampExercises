import Types "Types";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Int "mo:base/Int";

actor StudentWall {
  type Message = Types.Message;
  type Content = Types.Content;
  stable var messageId: Nat = 0;

  private func getHash(n: Nat) : Hash.Hash {
    return Text.hash(Nat.toText(n));
  };

  var wall = HashMap.HashMap<Nat,Message>(1, Nat.equal, getHash);

  public shared ({caller}) func writeMessage(c: Types.Content) : async Nat {
    let post : Message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    let index = messageId;
    wall.put(index, post);
    messageId += 1;
    return index;
  };

  public shared query func getMessage(messageId: Nat) : async Result.Result<Types.Message, Text> {
    let post : ?Message = wall.get(messageId);
    switch(post) {
      case(?post) {
        #ok(post);
      };
      case(_) {
        #err("The given Id isn't present in the wall");
       };
    };
  };

  public shared ({caller}) func updateMessage(messageId: Nat, c: Types.Content) : async Result.Result<(), Text> {
    let oldPost = wall.get(messageId);

    switch(oldPost) {
      case(?Message) {
          if (Message.creator != caller) {
            return #err("You can't modify a post you don't created.");
          };

          let newPost : Message = {
            content = c;
            vote = Message.vote;
            creator = Message.creator;
          };
          wall.put(messageId, newPost);
          #ok();
        };
      case(_) { 
        #err("The given ID isn't present in the wall");
      };
    };
  };

  public shared ({caller}) func deleteMessage(messageId: Nat) : async Result.Result<(), Text> {
    let post = wall.get(messageId);

    switch(post) {
      case(?Message) { 
        if (Message.creator != caller) {
          return #err("You can't delete a post you don't created");
        };
        wall.delete(messageId);
        #ok();
       };
      case(_) { 
        #err("The given Id isn't present in the wall");
      };
    };
  };

  public shared func upVote(messageId: Nat) : async Result.Result<(), Text> {
    let post = wall.get(messageId);
    switch(post) {
      case(?Message) { 
        let newPost : Message = {
          content = Message.content;
          vote = Message.vote + 1;
          creator = Message.creator;
        };
        wall.put(messageId, newPost);
        #ok();
       };
      case(_) {
        #err("The post of the given ID don't exist");
       };
    };
  };

  public shared func downVote(messageId: Nat) : async Result.Result<(), Text> {
    let post = wall.get(messageId);
    switch(post) {
      case(?Message) { 
        let newPost: Message = {
          content = Message.content;
          vote = Message.vote - 1;
          creator = Message.creator;
        };
        wall.put(messageId, newPost);
        #ok();
       };
      case(_) { 
        #err("The post of the given ID don't exist");
      };
    };
  };

  public shared query func getAllMessages() : async [Message] {
    return Iter.toArray(wall.vals());
  };


  public shared query func getAllMessagesRanked() : async [Message] {
    var posts = Iter.toArray(wall.vals());
    return Array.sort(posts, compare);
  };

  private func compare(post1: Message, post2: Message) : Order.Order {
    switch(Int.compare(post1.vote, post2.vote)) {
      case(#greater) { 
        return #less;
       };
      case(#less) { 
        return #greater;
      };
      case(_){
        return #equal
      };
    };
  };
};