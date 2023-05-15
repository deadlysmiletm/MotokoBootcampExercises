import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";

actor HomeworkDiary {
  type Time = Time.Time;
  public type Homework = {
    title : Text;
    description : Text;
    dueDate : Time;
    completed : Bool;
  };

  let homeworkDiary = Buffer.Buffer<Homework>(1);

  public shared func addHomework(homework : Homework) : async Nat {
    var index = homeworkDiary.size();
    homeworkDiary.add(homework);
    return index;
  };

  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id >= homeworkDiary.size()) {
      #err("Homework with given ID don't exist.");
    } else {
      #ok(homeworkDiary.get(id));
    };
  };

  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      #err("Homework with given ID don't exist");
    } else {
      homeworkDiary.put(id, homework);
      #ok();
    };
  };

  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      #err("Homework with given ID don't exist.");
    } else {
      let oldHomework = homeworkDiary.get(id);
      var newHomework : Homework = {
        title = oldHomework.title;
        description = oldHomework.description;
        dueDate = oldHomework.dueDate;
        completed = true;
      };

      homeworkDiary.put(id, newHomework);
      #ok();
    };
  };

  public shared query func getAllHomework() : async [Homework] {
    return homeworkDiary.toArray();
  };

  public shared query func getPendingHomework() : async [Homework] {
    let pendings = Buffer.Buffer<Homework>(2);

    for (item in homeworkDiary.vals()) {
      if (item.completed == false) {
        pendings.add(item);
      };
    };

    return pendings.toArray();
  };

  public shared func searchHomework(searchTerm : Text) : async [Homework] {
    let results = Buffer.Buffer<Homework>(1);

    for (item in homeworkDiary.vals()) {
      if (Text.contains(item.title, #text searchTerm) or Text.contains(item.description, #text searchTerm)) {
        results.add(item);
      };
    };

    return results.toArray();
  };
};
