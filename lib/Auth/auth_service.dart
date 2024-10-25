import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal/DataBase/write_db.dart';
import 'package:meal/Models/user_id.dart';
// import 'package:google_sign_in/google_sign_in.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
// create a user object based on the firebase user
  UserID? userFromFirebase(User? user){
    return user != null ? UserID(uid: user.uid) : null;
  }

  //auth change of user stream
  Stream<UserID?> get UserStream{
    return _auth.authStateChanges().map(userFromFirebase);
  }

  // final googlesignin = GoogleSignIn();

  // GoogleSignInAccount? _user;

  // GoogleSignInAccount get user => _user!;


  // Future googleLogin() async{
  //   try {
  //     final googleuser = await googlesignin.signIn();
  //     if (googleuser == null) return;
  //     _user = googleuser;
  //
  //     final googleAuth = await googleuser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     UserCredential result =
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     User? user = result.user;
  //     return userFromFirebase(user);
  //   } catch(e){
  //     print(e.toString());
  //     return null;
  //   }
  //
  //   // notifyListeners();
  // }

  Future registerWEP(String email, String password,String First_name,String Last_name,String Phone_number) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      print(user?.uid);
      //create a new document for the user with uid
      await Write(uid: user!.uid).addUser(First_name, email);
      // ProfileState().user(user!.uid);
      // DatabaseService(uid:user!.uid).getuserInfo(user!.uid);
      return userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in with email and password

  Future Signin_WEP(email, password) async {
    try {
      // await Firebase.initializeApp();
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      // DatabaseService(uid:user!.uid).getuserInfo();
      // print(DatabaseService(uid:user!.uid).getuserInfo(user!.uid));
      // ProfileState().user(user!.uid);
      print(user);
      return userFromFirebase(user);

      //create a new document for the user with uid
      // await databaseservice(uid: user!.uid).updateUserData('0', 'new_member', 100);
      // return _userfromfirebaseuser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future sign_out() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}
