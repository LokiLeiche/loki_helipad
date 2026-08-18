# LOKI_HELIPAD

A FiveM Script that adds movable helipads to your MLO! Can be used with any framework.
This used to be closed source and paid, but since I closed my shop a couple of months ago, I though why not open source it. Have fun with it!

## Install
Firstly, this script is meant to be used in combination with any MLO of your choice that already includes a helipad fit for this purpose.
For example, something like this random [Air Rescue MLO](https://www.youtube.com/watch?v=yCSm0XGsEDo) I found on youtube. I didn't test that specific MLO and am not trying to advertise it, just so you can see what I mean. It should have the helipad as it's own seperate prop, so this script can spawn it.

The helipad prop is probably part of the MLO by default. For this to work, you need to edit the .ymap file(s) of your MLO and remove any mention of the helipad, so it can instead be spawned by this script.
Additionally, the helipad prop needs a .ytyp to be loaded properly, so you need to create that yourself if the MLO doesn't come with one by default. Also, add this line to the `fxmanifest.lua` of the MLO for the .ytyp file to be effective:
If the helipad model doesn't load, add this line to the fxmanifest.lua of your MLO:
```
data_file 'DLC_ITYP_REQUEST' 'stream/helipad.ytyp'
```
Obviously replace the file path/name with your actual file.

Now just download the latest release and unzip it in your resources folder, or clone the repository and advance to the next step.



## Configuration
Head over to the `config.lua` file, there you should find everything you need.
These are the most important settings you should change:
* `Config.HelipadModel` - Set this to the actual model name of the helipad prop from your MLO.
* `Config.Helipads` - Here you can configure as many helipads as you'd like / your MLO supports. Read the comments for details on the specific parameters. Open an Issue if you have any questions.


## If you encounter any problems
Feel free to open an issue or a PR any time. I'm not very active in FiveM anymore, but if you open an issue or a PR I will take a look at it as soon as I have the time to do so.
