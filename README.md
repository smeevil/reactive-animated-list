# Reactive Animated List

### What does it do ?

This plugin will create a reactive animated list that you can use in Meteor. If you update or filter your collection/cursor it will be automatically reflected in the layout using animations.

For the animations it automatically detects and uses [Greensock GSAP](https://greensock.com/gsap) if it is available in your project. If not it will fall back to jQuery.
 
### Preview :
![img](https://s3.amazonaws.com/f.cl.ly/items/1p1o0t1R2V3x2H1R3N1B/Screen%20Recording%202015-01-09%20at%2004.32%20pm.gif)

### Why?

I was looking for a solution that would help me animate newly inserted templates in a list that was ordered by newest first. Using the default options of just rendering your collection in an each block made for a jarring user experience when a **new item** would be **added** or **removed** in this way. For example you are looking at an item and all of the sudden you see something flicker and you are looking at a different item. Using an animation makes for a more **natural transition** and understanding of what happend. As I could not find any **_easy_** solution yet, I started to make one myself.

### Usage

**Installation:**

~~~js
meteor add smeevil:reactive-animated-list
~~~

GSAP is a fast animation library that is hardware accelerated and has a lot of easing options. You can use this to significantly speed up the animations by installing the package in your project with ```meteor add infinitedg:gsap```

**Basic usage:**

The most basic option to use it in your templates is as follows :
~~~js
{{> reactiveList cursor=exampleDataCursor template='exampleData')}}
~~~

You can pass options to manage the animation duration, which easing to use and which animation engine
~~~js
{{> reactiveList cursor=exampleDataCursor template='exampleData' animationDuration=0.5 easing='Power0.easeInOut' engine='gsap'}}
~~~


**Experimental table layout:**

If you rather add items to a table, then use the new experimental options layout="table" like so :

~~~js
<table>
	<thead>
		<tr>
			<th>example</th>
		</tr>
	</thead>
			
	{{> reactiveList cursor=exampleDataCursor template='exampleData' 	layout="table")}}
</table>
~~~
This will add the items in a &lt;tbody/&gt; holder with &lt;tr/&gt; elements , so your template should only have the &lt;td/&gt; elements


Licensed under the WTFPL License. See the `LICENSE` file for details.
