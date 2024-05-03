// Importing necessary modules for primitive operations, natural numbers, and principal (actor identity)
import Prim "mo:prim";
import Nat "mo:nat";
import Principal "mo:base/Principal";

// Actor definition for Decentragram, a decentralized application for managing land and images
actor Decentragram {

    // Define a type for Land with various attributes
    type Land = {
        id : Nat;          // Unique identifier for the land
        hash : Text;       // A unique hash representing the land's identifier
        title : Text;      // Title of the land
        landType : Text;   // Type of land (e.g., agricultural, residential, etc.)
        country : Text;    // Country where the land is located
        soilType : Text;   // Type of soil on the land
        landDetails : Text; // Additional details about the land
        price : Text;      // Price of the land
        message : Text;    // Optional message or description
        grantAmount : Nat; // Amount granted/booked for the land
        user : Principal;  // Owner of the land (principal identifier)
    };

    // Define a type for Image associated with land
    type Image = {
        id : Nat;          // Unique identifier for the image
        hash : Text;       // A unique hash for the image
        landId : Text;     // Identifier for the associated land
        grantAmount : Nat; // Amount of funds granted with this image
        user : Principal;  // Principal (actor) that owns this image
    };

    // Variables to store lists of lands and images, along with their counts
    var lands : [Land] = []; // List of all lands
    var landsCount : Nat = 0; // Counter for lands
    var images : [Image] = []; // List of all images
    var imagesCount : Nat = 0; // Counter for images

    var desiredAmount : Nat = 100; // The desired amount to consider a land as booked

    // Function to upload a new land with required details
    public func uploadLand(
        hash : Text,       // Unique identifier for the land
        title : Text,      // Title of the land
        landType : Text,   // Type of land
        country : Text,    // Country where the land is located
        soilType : Text,   // Type of soil
        landDetails : Text, // Additional details
        message : Text,    // Optional message
        price : Text       // Price of the land
    ) : async {
        // Ensure the land hash and title are not empty
        if (Text.isEmpty(hash) || Text.isEmpty(title)) {
            return Prim.unit; // Return without action if invalid data
        };

        // Increment the lands counter
        landsCount += 1;

        // Create a new land object with provided details
        let land : Land = {
            id = landsCount; // Assign a unique ID
            hash = hash;     // Set the land's hash
            title = title;   // Set the title
            landType = landType; // Set the land type
            country = country;   // Set the country
            soilType = soilType; // Set the soil type
            landDetails = landDetails; // Additional details
            price = price;     // Set the price
            message = message; // Set the message
            grantAmount = 0;   // Initialize grant amount to zero
            user = Principal.fromActor(this); // Set the user (owner)
        };

        // Append the new land to the list of lands
        lands := lands # [land];

        return Prim.unit; // Return without additional action
    };

    // Function to book land, given its ID
    public func bookLand(id : Nat) : async {
        // Ensure a valid land ID is provided
        if (id == 0 || id > landsCount) {
            return Prim.unit; // Return without action if invalid ID
        };

        // Get the land by its ID (adjusting for 1-based indexing)
        let land = lands[id - 1];

        // Check if the caller's balance plus current grant amount meets the desired amount
        if (land.grantAmount + ?caller.callerBalance < desiredAmount) {
            return Prim.unit; // Return if funds are insufficient
        };

        // Transfer the caller's balance to the land's owner
        await (?land.user).transfer(caller, caller.callerBalance);

        // Update the grant amount for the booked land
        lands[id - 1].grantAmount := land.grantAmount + caller.callerBalance;

        return Prim.unit; // Return indicating successful booking
    };

    // Function to set the desired escrow amount
    public func setDesiredAmount(amount : Nat) : async {
        desiredAmount := amount; // Set the desired escrow amount
    };

    // Function to upload an image associated with land
    public func uploadImage(hash : Text, landId : Text) : async {
        // Ensure non-empty hash and land ID are provided
        if (Text.isEmpty(hash) || Text.isEmpty(landId)) {
            return Prim.unit; // Return without action if invalid data
        };

        // Increment the images counter
        imagesCount += 1;

        // Create a new image object with provided details
        let image : Image = {
            id = imagesCount; // Assign a unique ID for the image
            hash = hash;      // Set the image's hash
            landId = landId;  // Set the associated land's ID
            grantAmount = 0;  // Initialize grant amount to zero
            user = Principal.fromActor(this); // Set the user (owner)
        };

        // Append the new image to the list of images
        images := images # [image];

        return Prim.unit; // Return without additional action
    };
};
