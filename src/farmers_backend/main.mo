import Prim "mo:prim";
import Nat "mo:nat";
import Principal "mo:base/Principal";

actor Decentragram {

    type Land = {
        id : Nat;
        hash : Text;
        title : Text;
        landType : Text;
        country : Text;
        soilType : Text;
        landDetails : Text;
        price : Text;
        message : Text;
        grantAmount : Nat;
        user : Principal;
    };

    type Image = {
        id : Nat;
        hash : Text;
        landId : Text;
        grantAmount : Nat;
        user : Principal;
    };

    var lands : [Land] = [];
    var landsCount : Nat = 0;

    var images : [Image] = [];
    var imagesCount : Nat = 0;

    var desiredAmount : Nat = 100; // Set the desired escrow amount here

    public func uploadLand(
        hash : Text,
        title : Text,
        landType : Text,
        country : Text,
        soilType : Text,
        landDetails : Text,
        message : Text,
        price : Text
    ) : async {
        if (Text.isEmpty(hash) || Text.isEmpty(title)) {
            // Require non-empty hash and title
            return Prim.unit;
        };

        landsCount += 1;
        let land : Land = {
            id = landsCount;
            hash = hash;
            title = title;
            landType = landType;
            country = country;
            soilType = soilType;
            landDetails = landDetails;
            price = price;
            message = message;
            grantAmount = 0;
            user = Principal.fromActor(this);
        };
        lands := lands # [land];
        return Prim.unit;
    };

    public func bookLand(id : Nat) : async {
        if (id == 0 || id > landsCount) {
            // Require valid land ID
            return Prim.unit;
        }

        let land = lands[id - 1];

        if (land.grantAmount + ?caller.callerBalance < desiredAmount) {
            // Require sufficient funds
            return Prim.unit;
        }

        // Transfer funds to the seller's address (escrow release)
        await (?land.user).transfer(caller, caller.callerBalance);

        // Update the grantAmount
        lands[id - 1].grantAmount := land.grantAmount + caller.callerBalance;

        return Prim.unit;
    };

    public func setDesiredAmount(amount : Nat) : async {
        desiredAmount := amount;
    };

    // Images

    public func uploadImage(hash : Text, landId : Text) : async {
        if (Text.isEmpty(hash) || Text.isEmpty(landId)) {
            // Require non-empty hash and landId
            return Prim.unit;
        }

        imagesCount += 1;
        let image : Image = {
            id = imagesCount;
            hash = hash;
            landId = landId;
            grantAmount = 0;
            user = Principal.fromActor(this);
        };
        images := images # [image];
        return Prim.unit;
    };
};
