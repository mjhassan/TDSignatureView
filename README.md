TDSignatureView for iOS
===========================
TDSignatureView is a simple custom view class with free hand drawing support. If you need a view to draft 
something or your app needs to take and store a signature, then TDSignatureView is the just class you need.
It will give you nice and smooth curve while drawing, like pen and paper.

How to use it
=============
* Copy the TDSignatureView folder in your project.

*Drag and drop method:
  - Drag a UIView in your xib file or scene (ios 5 or later)
  - Go to the Identity Inspector and write TDSignatureView in the class name field.
  - import TDSignatureView.h file in your interface class
  - Declare an TDSignatureView type IBOutlet, like
    ```
        @property (strong, nonatomic) IBOutlet TDSignatureView *your_property_name;
    ```
  - Synthesize it in your implementation class
  - Now call the method ```[your_property_name getDrawingImage]``` to get the drawing you are about to draw and store 
    it if you like.

*Programmatically:
  - Import TDSignatureView.h file in your interface class
  - Allocate and initialize a TDSignatureView type variable in viewDidLoad method with frame size. e.g.
    ```
        TDSignatureView *your_property_name = [[TDSignatureView alloc] initWithFrame: your_view_frame ];
    ```
  - Add it to the main view or whatever view you like.
  - Now call the method ```[your_property_name getDrawingImage]``` to get the drawing you are about to draw and store 
    it if you like.

Requirements
============
This project uses ARC. If you are not using ARC in your project, add '-fno-objc-arc' as a compiler flag for all the 
files in this project. XCode 4.4 is required for auto-synthesis.

Credit
======
The original credit of this work goes to Aikel Khan and mobiletut+. Thanks man, for your nice post.
