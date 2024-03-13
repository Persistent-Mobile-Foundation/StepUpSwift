Persistent Mobile Foundation
===
## StepUpSwift
A sample application demonstrating the use of multiple challenge handlers.

Tutorials
https://pmf.persistentproducts.com/tutorials/en/foundation/9.0/authentication-and-security/user-authentication/

Usage
Use either Maven, MobileFoundation CLI or your IDE of choice to build and deploy the available ResourceAdapter and UserLogin adapters.
The UserAuthentication Security Check adapter can be found in https://github.com/Persistent-Mobile-Foundation/SecurityCheckAdapters.

2. From a command-line window, navigate to the project's root folder and run the following commands:
 -  `pmfdev app register` - to register the application
 - `pmfdev app push` - to add the following scope mappings:
     - `accessRestricted` to `StepUpUserLogin`.
     - `transferPrivilege` to both `StepUpUserLogin` and `StepUpPinCode`.

3. In Xcode, run the application


