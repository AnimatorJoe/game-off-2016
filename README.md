# Westlake APC's Submission to GitHub Game Off 2016

![GitHub Game Off 2016 Theme is Hacking, Modding, or Augmenting](https://cloud.githubusercontent.com/assets/121322/19498019/d8827370-9543-11e6-82d8-6da822b6147b.png)

## Our Submission

We have the entire month of November to create a game *loosely* based on the theme **hacking, modding and/or augmenting**.

We chose to make a game focusing around _modding_'s second unofficial meaning: moderation. In the game, you control a federally commissioned team to _moderate_ the behavior of bad guys working for the CIA to lower their sentences, in an insanely large and chaotic rendition of _White Collar_, the bad guys being a user-controlled SpriteKit particle effect.

## How to build

To build our app on a macOS 10.12 environment with Xcode 8 and Cocoapods, first install the Cocoapods dependencies.

```bash
pod install
```

Then, use the `xcrun` command line tool as follows, to compile and run:

```bash
xcrun xcodebuild \
  -scheme iOS \
  -workspace GameOff.xcworkspace \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=10.0'
```

## How to participate

* [Sign up for a free personal account][github-signup] if you don't already have one.
* Fork [this repository][game-off-repo] to your personal account (or to a [free organization account][github-signup-org]).
* Clone the repository on your computer and build your game.
* Push your game source code to your forked repository before Dec 1st.
* Update the `README.md` file to include a description of your game, how/where to play/download it, how to build/compile it, what dependencies it has, etc.
* Submit your final game using this [form][wufoo-form].

## It's dangerous to go alone <img src="https://octodex.github.com/images/linktocat.jpg" height="40">

If you're **new to Git, GitHub, or version control**…

* [Git Documentation](https://git-scm.com/documentation) - everything you need to know about version control, and how to get started with Git.
* [GitHub Help](https://help.github.com/) - everything you need to know about GitHub.
* Questions about GitHub? Please [contact our Support team][github-support] and they'll be delighted to help you.
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
