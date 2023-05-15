import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Types "Types";


actor class Homework() {
  public type Homework = Types.Homework;

  var homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework tsk
  public shared func addHomework(homework : Homework) : async Nat {
    let lastHomeworkAddedIndex = homeworkDiary.size();
    homeworkDiary.add(homework);
    Debug.print("holiwis");
    //Debug.print(debug_show(homeworkDiary))
    return lastHomeworkAddedIndex;

    //Debug.print("holiwis");
    //Debug.print(debug_show(homeworkDiary[0]));
    //return lastHomeworkAddedIndex;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    //Result type allows us to return one specific type for success and another one for failure.
    if (id < homeworkDiary.size() and id >= 0) {
      return #ok(homeworkDiary.get(id));
      //#ok to indicate succesful output
    } else {
      return #err("HomeworkID is invalid!!!");
      //#err followed by the output with the specified error type
    }

  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size() and id >= 0) {
      //if statements here are weird, took 2hrs to do that, not funny
      homeworkDiary.put(id, homework);
      //put method in a buffer serves to update an object in certain index
      return #ok();
    } else {
      return #err("ID is invalid");
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    let homeworkOptional : ?Homework = homeworkDiary.getOpt(id);
    //Well here, the ?Homework type signals that the output might be that type or null.
    //  The getOpt method serves the purpose of querying for a value inside a buffer that maybe {doesn't exist.
    switch (homeworkOptional) {
      //nothing weird with the switch statement here, surprisingly
      case (null) {
        return #err("We did not find a homework with this ID: " # Nat.toText(id));
      };
      case (?homework) {
        let newHomework = {
          title = homework.title;
          description = homework.description;
          dueDate = homework.dueDate;
          completed = true;
        };
        homeworkDiary.put(id, newHomework);
        return #ok;
      };
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDiary.size() and id >= 0) {
      let homeworkToRemove = homeworkDiary.remove(id);
      //Not rocket science here, remove method just removes the object in the index.
      return #ok;
    } else {
      return #err("HomeworkID is invalid");
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let pendingList = Buffer.clone(homeworkDiary);
    pendingList.filterEntries(func(_, x) = (x.completed == false));//filterEntries receives a callback with a condition, pretty similar to .filter from JS(duh)
    Debug.print(debug_show(Buffer.toArray(pendingList)));
    return Buffer.toArray(pendingList);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let queryResult = Buffer.clone(homeworkDiary);
    queryResult.filterEntries(func(_, x) = (Text.contains(x.title, #text searchTerm) or Text.contains(x.description, #text searchTerm)));
    return Buffer.toArray(queryResult);
  };
};