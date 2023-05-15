import Type "types";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Error "mo:base/Error";

actor class Verifier() {
    type StudentProfile = Type.StudentProfile;
    type TestResult = Type.TestResult;
    type TestError = Type.TestError;
    let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

    public shared ({caller}) func addMyProfile(profile: StudentProfile) : async Result.Result<(), Text> {
        // if (Principal.isAnonymous(caller)) {
        //     return #err("You need to log in first before adding a profile");
        // };

        if (studentProfileStore.get(caller) != null) {
            return #err("You're already registered.");
        };
        studentProfileStore.put(caller, profile);
        return #ok();
    };

    public shared query ({caller}) func seeAProfile(p: Principal) : async Result.Result<StudentProfile, Text> {
        // if (Principal.isAnonymous(caller)) {
        //     return #err("You need to log in first before see a profile");
        // };
        let profile = studentProfileStore.get(p);
        switch (profile) {
            case (?StudentProfile) {
                return #ok(StudentProfile);
            };
            case (_) {
                return #err("There isn't a profile registered for this Principal");
            };
        };
    };

    public shared ({caller}) func updateMyProfile(profile: StudentProfile) : async Result.Result<(), Text> {
        // if (Principal.isAnonymous(caller)) {
        //     return #err("You need to log in first before see a profile");
        // };
        if (studentProfileStore.get(caller) == null) {
            return #err("You're not registered. Please, first add your profile.");
        };
        studentProfileStore.put(caller, profile);
        return #ok();
    };

    public shared ({caller}) func deleteMyProfile() : async Result.Result<(), Text> {
        // if (Principal.isAnonymous(caller)) {
        //     return #err("You need to log in first before see a profile");
        // };
        if (studentProfileStore.get(caller) == null) {
            return #err("You're not registered.");
        };
        studentProfileStore.delete(caller);
        return #ok();
    };

    public func test(canisterId: Principal) : async TestResult {
        let calculator = actor(Principal.toText(canisterId)) : actor {
          reset: shared () -> async Int;
          add: shared (x: Nat) -> async Int;
          sub: shared (x: Nat) -> async Int;
        };

        ignore calculator.reset();
        var result = await calculator.add(5);
        if (result != 5) {
            return #err(#UnexpectedValue("After add 5, result need to be 5 in this case."));
        };

        result := await calculator.sub(3);
        if (result != 2) {
            return #err(#UnexpectedValue("After add 5 and sub 3, result need to be 2 in this case."));
        };

        result := await calculator.reset();
        if (result != 0) {
            return #err(#UnexpectedValue("After reset, the result need to be 0."));
        };

        return #ok();
    };

    public shared query ({caller}) func myPrincipal() : async Principal {
      return caller;
    };

    public func verifyOwnership(canisterId: Principal, p: Principal) : async Bool {
        let controllers = await getCanisterControllers(canisterId);
        switch (Array.find<Principal>(controllers, func controllerP = controllerP == p)) {
          case (?Principal)  {
            return true;
          };
          case (_) {
            return false;
          };
        };
    };

    public shared ({caller}) func verifyWork(canisterId: Principal, p: Principal) : async Result.Result<(), Text> {
        // if (Principal.isAnonymous(caller)) {
        //     return #err("You need to log in first before see a profile");
        // };
        switch (studentProfileStore.get(p)) {
            case (?StudentProfile) {
              let testResult = await test(canisterId);
              if (testResult != #ok) {
                  return #err("The work don't passed the test. Try again.");
              };

              let verifyResult = await verifyOwnership(canisterId, p);
              if (verifyResult == false) {
                  return #err("You don't had ownership of this canister.");
              };

              let updatedProfile : StudentProfile = {
                name = StudentProfile.name;
                team = StudentProfile.team;
                graduate = true;  
              };
              studentProfileStore.put(p, updatedProfile);
              return #ok();
            };
            case (_) {
                return #err("This Principal isn't a registered student.");
            };
        };
    };

    private func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
      let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
      let words = Iter.toArray(Text.split(lines[1], #text(" ")));
      var i = 2;
      let controllers = Buffer.Buffer<Principal>(0);
      while (i < words.size()) {
          controllers.add(Principal.fromText(words[i]));
          i += 1;
      };
      Buffer.toArray<Principal>(controllers);
  };

  private func getCanisterControllers(canisterId: Principal) : async [Principal] {
    let icController = actor("aaaaa-aa") : actor {
        canister_status : { 
          canister_id: Principal
        } -> async {
          controllers: [Principal] };
      };
    try {
      let status = await icController.canister_status({ canister_id = canisterId});
      return status.controllers;
    } catch(e) {
      return parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
    };
  };
};