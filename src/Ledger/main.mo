import Text "mo:base/Text";
import Nat "mo:base/Nat";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Account "account";

actor MotoCoin {
  type Account = Account.Account;

  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  stable let tokenName: Text = "MotoCoin";
  stable let tokenSymbol: Text = "MOC";
  var supply: Nat = 0;

  public shared query func name() : async Text {
    return tokenName;
  };

  public shared query func symbol() : async Text {
    return tokenSymbol;
  };

  public shared query func totalSupply() : async Nat {
    return supply;
  };

  public shared query func balanceOf(account: Account) : async (Nat) {
    return Option.get<Nat>(ledger.get(account), 0);
  };

  public shared func transfer(from: Account, to: Account, amount: Nat) : async Result.Result<(), Text> {
    let fromBalance = Option.get<Nat>(ledger.get(from), 0);
    if (fromBalance >= amount) {
      ledger.put(from, fromBalance - amount);
      ledger.put(to, Option.get<Nat>(ledger.get(to), 0) + amount);
      return #ok();
    };

    return #err("The given account don't hade enought tokens");
  };

  public shared func airdrop() : async Result.Result<(), Text> {
    let canister = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let allAccounts = await canister.getAllStudentsPrincipal();
    if (allAccounts.size() == 0) {
      return #err("The account list is empty");
    };
    for(item in allAccounts.vals()) {
      let acc : Account = { owner = item; subaccount = null };
      let balance = Option.get<Nat>(ledger.get(acc), 0);
      ledger.put(acc, balance + 100);
      supply += 100;
    };

    return #ok();
  };
};