ThreadOne-For-ADN
=================

A direct messaging OS X application for App.Net

ThreadOne is available on the [Mac App Store](https://itunes.apple.com/us/app/threadone/id788290980?ls=1&mt=12). With the failure of ADN as a service, and the subsequent destruction of any new users of ThreadOne, I have determined that providing the source code would be the best use of my time investment.

If you wish to run this application yourself, you'll need an [ADN Developer Key](https://account.app.net/settings/); plug that info into the INOAppDelegate.m file; after that you should be able to just "Build & Run".

Some notes about this application:

* It uses both [ADNKit](https://github.com/joeldev/ADNKit) and [SocketRocket](https://github.com/square/SocketRocket) to handle access to the ADN API. It's always felt kludgy to have two concurrent mechanisms for working with ADN, but this was the most effective way I'd found to provide realtime interactions.
* Caching is done using locally-stored property lists, rather than something more robust like Core Data. An earlier version of T1 did use Core Data, but a late rewrite and vanshing time forced me to abandon that method. Long story; if T1 had worked out better, moving back to Core Data was on the list.
* There's lots of interesting stuff in the UI folder. Browsers may be interested in the logic that implements the "list-switching" interface, swiping back and forth between channel list and chat views.
* ThreadOne was written largely over a period of weekends evenings in the Fall and early Winter of 2013. I'd hoped it would do better, but I hope this code can help someone.

Contributions & Terms of Use
-----------
I'm not looking to improve this application; it's a commercial failure. Feel free to fork and play with it as you wish. If you wind up using anything here, an attribution and link back to this project would be appreciated.
