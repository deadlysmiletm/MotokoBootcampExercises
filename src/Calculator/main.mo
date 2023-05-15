import Int "mo:base/Int";
import Float "mo:base/Float";

actor Calculator
{
  stable var counter : Float = 0;

  public func add(x : Float) : async Float 
  {
    counter:= counter + x;
    return counter;
  };

  public func sub(x : Float) : async Float 
  {
    counter:= counter - x;
    return counter;
  };

  public func mul(x : Float) : async Float
  {
    counter:= counter * x;
    return counter;
  };

  public func div(x : Float) : async ?Float
  {
    if (x == 0)
    {
      return null;
    };

    counter:= counter / x;
    return ?counter;
  };

  public func reset() : async () 
  {
    counter:= 0;
  };

  public query func see() : async Float 
  {
    return counter;
  };

  public func power(x : Float) : async Float
  {
    counter:= Float.pow(counter, x);
    return counter;
  };

  public func sqrt() : async Float
  {
    counter:= Float.sqrt(counter);
    return counter;
  };

  public func floor() : async Int 
  {
    counter:= Float.floor(counter);
    return Float.toInt(counter);
  };
};

