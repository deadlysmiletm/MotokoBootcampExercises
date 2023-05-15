import Result "mo:base/Result";

module {
    public type StudentProfile = {
        name: Text;
        team: Text;
        graduate: Bool;
    };

    public type TestError = {
        #UnexpectedValue: Text;
        #UnexpectedError: Text;
    };
    public type TestResult = Result.Result<(), TestError>;
};