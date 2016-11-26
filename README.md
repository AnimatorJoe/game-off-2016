# Immolation Organization

![GitHub Game Off 2016 Theme is Hacking, Modding, or Augmenting](https://cloud.githubusercontent.com/assets/121322/19498019/d8827370-9543-11e6-82d8-6da822b6147b.png)

## Our Submission

We are the Westlake Accessible Programming Club, a team of high-schoolers interested in the development of everything from games to kernels in the high-level language Swift. We're excited this year to take the entire month of November to create a game *loosely* based on the theme **hacking, modding and/or augmenting** for the developer services company GitHub's annual game development competition, the Game Off.

In our submission, you control a federally commissioned team to _**moderate**_ a cluster of bad guys working for the CIA to lower their sentences, which _**hack**_ away at evil robots and aliens, the bad guys being a user-controlled SpriteKit particle effect. Pretty much, it's just an insanely enormous and chaotic rendition of DC Comics' _Suicide Squad_.

## How to build

To build our app on a macOS 10.12 environment with Xcode 8 and Cocoapods, first install the Cocoapods dependencies.

```bash
pod install
```

Then, use the `xcrun` command line tool as follows, to compile an intermediate binary:

```bash
xcrun xcodebuild \
  -scheme iOS \
  -workspace GameOff.xcworkspace \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.0'
```

Then, just launch Simulator and run _Immolation Organization_.

## How to play

In _Immolation Organization_, you moderate a mob of baddies with the intent of hacking away at and destroying alien spacecrafts! You do so by pointing at and touching places for the mob to travel. They'll always deteriorate and diminish the spacecrafts, but depending on who's bigger, the mob or the spacecrafts, they will either enlarge or shrink.

## How to participate

* [Sign up for a free personal account][github-signup] if you don't already have one.
* Fork [this repository][game-off-repo] to your personal account (or to a [free organization account][github-signup-org]).
* Clone the repository on your computer and build your game.
* Push your game source code to your forked repository before Dec 1st.
* Update the `README.md` file to include a description of your game, how/where to play/download it, how to build/compile it, what dependencies it has, etc.
* Submit your final game using this [form][wufoo-form].

## Dependencies

We used many other tools and creative works to build _Immolation Organization_.

| Creative Work | Copyright Owner | License              |
|---------------|-----------------|----------------------|
| Fiber2D       | Andrey Volodin  | BSD Simplified       |
| GotItem.mp3   | Kastenfrosch    | CC-0 (Public Domain) |
| Odyssey       | Kevin MacLeod   | CC-BY-3.0            |

## It's dangerous to go alone <img src="https://octodex.github.com/images/linktocat.jpg" height="40">

If you're **new to Git, GitHub, or version control**…

* [Git Documentation](https://git-scm.com/documentation) - everything you need to know about version control, and how to get started with Git.
* [GitHub Help](https://help.github.com/) - everything you need to know about GitHub.
* Questions about GitHub? Please [contact their Support team][github-support] and they'll be delighted to help you.
* Questions specific to the GitHub Game Off? Please [create an issue][game-off-repo-issues]. This will be the official FAQ.

The official Twitter hashtag for the Game Off is `#ggo16`. We look forward to playing with your creations.

GLHF! <3

<!-- links -->
[game-off-repo]:        https://github.com/github/game-off-2016/
[game-off-repo-issues]: https://github.com/github/game-off-2016/issues
[git-documentation]:    https://git-scm.com/documentation
[github-help]:          https://help.github.com/
[github-signup]:        https://github.com/signup/free  
[github-signup-org]:    https://github.com/organizations/new
[github-support]:       https://github.com/contact?form%5Bsubject%5D=GitHub%20Game%20Off
[wufoo-form]:           https://gameoff.wufoo.com/forms/game-off-2016/
