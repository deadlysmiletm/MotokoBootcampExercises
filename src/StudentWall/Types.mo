import Principal "mo:base/Principal";

module {
    public type Content = {
        #Text: Text;
        #Image: Blob;
        #Video: Blob;
        #Survey: Blob;
    };
    public type Message = {
        content: Content;
        vote: Int;
        creator: Principal;
    };
};