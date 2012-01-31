////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


package spark.components
{
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.ui.Keyboard;

import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.LayoutDirection;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.PropertyChangeEvent;
import mx.events.TouchScrollEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.Group;
import spark.components.supportClasses.ScrollerLayout;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.TouchScrollingEasing;
import spark.core.IViewport;
import spark.core.NavigationUnit;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;

use namespace mx_internal;

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

//--------------------------------------
//  TouchScroll events
//--------------------------------------

// touchScrollStarting defined on UIComponent
// touchScrollStart defined on UIComponent

/**
 *  Dispatched as the user is drag scrolling.
 * 
 *  <p>The <code>event.dragX</code> and <code>event.dragY</code>
 *  properties are set to the distance dragged since the initial 
 *  mouseDown/touchBegin occurred.</p>
 *
 *  @eventType mx.events.TouchScrollEvent.TOUCH_SCROLL_DRAG
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="touchScrollDrag", type="mx.events.TouchScrollEvent")]

/**
 *  Dispatched when a user flicks or throw scrolls a list.
 * 
 *  <p>The <code>event.velocityX</code> and <code>event.velocityY</code>
 *  properties are set to the velocity the user threw the list.</p>
 *
 *  @eventType mx.events.TouchScrollEvent.TOUCH_SCROLL_THROW
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="touchScrollThrow", type="mx.events.TouchScrollEvent")]

/**
 *  Dispatched at the end of a scroll throw operation.
 * 
 *  <p>If no throw occurs, this is dispatched immediately on 
 *  mouseUp/touchEnd.  However, if a scroll throw does occur, then
 *  this is dispatched after the throw has completely finished.</p>
 *
 *  @eventType mx.events.TouchScrollEvent.TOUCH_SCROLL_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="touchScrollEnd", type="mx.events.TouchScrollEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  Indicates under what conditions the horizontal scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  horizontalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentWidth is larger than its width.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the Scroller component.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="horizontalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

/**
 * @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  Indicates under what conditions the vertical scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  verticalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentHeight is larger than its height.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the Scroller component.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
     */ 
[Style(name="verticalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]


//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]
    
[DefaultProperty("viewport")]

[IconFile("Scroller.png")]

/**
 *  The Scroller component displays a single scrollable component, 
 *  called a viewport, and horizontal and vertical scroll bars. 
 *  The viewport must implement the IViewport interface.  Its skin
 *  must be a derivative of the Group class.
 *
 *  <p>The Spark Group, DataGroup, and RichEditableText components implement 
 *  the IViewport interface and can be used as the children of the Scroller control,
 *  as the following example shows:</p>
 * 
 *  <pre>
 *  &lt;s:Scroller width="100" height="100"&gt;
 *       &lt;s:Group&gt; 
 *          &lt;mx:Image width="300" height="400" 
 *               source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
 *       &lt;/s:Group&gt;        
 *  &lt;/s:Scroller&gt;</pre>     
 *
 *  <p>The size of the Image control is set larger than that of its parent Group container. 
 *  By default, the child extends past the boundaries of the parent container. 
 *  Rather than allow the child to extend past the boundaries of the parent container, 
 *  the Scroller specifies to clip the child to the boundaries and display scroll bars.</p>
 *
 *  <p>Not all Spark containers implement the IViewPort interface. 
 *  Therefore, those containers, such as the Border and SkinnableContainer containers, 
 *  cannot be used as the direct child of the Scroller component.
 *  However, all Spark containers can have a Scroller component as a child component. 
 *  For example, to use scroll bars on a child of the Spark Border container, 
 *  wrap the child in a Scroller component. </p>
 *
 *  <p>To make the entire Border container scrollable, wrap it in a Group container. 
 *  Then, make the Group container the child of the Scroller component,
 *  For skinnable Spark containers that do not implement the IViewport interface, 
 *  you can also create a custom skin for the container that 
 *  includes the Scroller component. </p>
 * 
 *  <p>The IViewport interface defines a viewport for the components that implement it.
 *  A viewport is a rectangular subset of the area of a container that you want to display, 
 *  rather than displaying the entire container.
 *  The scroll bars control the viewport's <code>horizontalScrollPosition</code> and
 *  <code>verticalScrollPosition</code> properties.
 *  scroll bars make it possible to view the area defined by the viewport's 
 *  <code>contentWidth</code> and <code>contentHeight</code> properties.</p>
 *
 *  <p>You can combine scroll bars with explicit settings for the container's viewport. 
 *  The viewport settings determine the initial position of the viewport, 
 *  and then you can use the scroll bars to move it, as the following example shows: </p>
 *  
 *  <pre>
 *  &lt;s:Scroller width="100" height="100"&gt;
 *      &lt;s:Group
 *          horizontalScrollPosition="50" verticalScrollPosition="50"&gt; 
 *          &lt;mx:Image width="300" height="400" 
 *              source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
 *      &lt;/s:Group&gt;                 
 *  &lt;/s:Scroller&gt;</pre>
 * 
 *  <p>The scroll bars are displayed according to the vertical and horizontal scroll bar
 *  policy, which can be <code>auto</code>, <code>on</code>, or <code>off</code>.
 *  The <code>auto</code> policy means that the scroll bar will be visible and included
 *  in the layout when the viewport's content is larger than the viewport itself.</p>
 * 
 *  <p>The Scroller skin layout cannot be changed. It is unconditionally set to a 
 *  private layout implementation that handles the scroll policies.  Scroller skins
 *  can only provide replacement scroll bars.  To gain more control over the layout
 *  of a viewport and its scroll bars, instead of using Scroller, just add them 
 *  to a <code>Group</code> and use the scroll bar <code>viewport</code> property 
 *  to link them together.</p>
 *
 *  <p>The Scroller control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>0</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.ScrollerSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Scroller&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Scroller
 *   <strong>Properties</strong>
 *    measuredSizeIncludesScrollBars="true"
 *    minViewportInset="0"
 *    viewport="null"
 *  
 *    <strong>Styles</strong>
 *    alignmentBaseline="use_dominant_baseline"
 *    alternatingItemColors=""
 *    baselineShift="0.0"
 *    blockProgression="TB"
 *    breakOpportunity="auto"
 *    cffHinting="horizontal_stem"
 *    color="0"
 *    contentBackgroundAlpha=""
 *    contentBackgroundColor=""
 *    digitCase="default"
 *    digitWidth="default"
 *    direction="LTR"
 *    dominantBaseline="auto"
 *    firstBaselineOffset="auto"
 *    focusColor=""
 *    focusedTextSelectionColor=""
 *    fontFamily="Times New Roman"
 *    fontLookup="device"
 *    fontSize="12"
 *    fontStyle="normal"
 *    fontWeight="normal"
 *    horizontalScrollPolicy="auto"
 *    inactiveTextSelection=""
 *    justificationRule="auto"
 *    justificationStyle="auto"
 *    kerning="auto"
 *    leadingModel="auto"
 *    ligatureLevel="common"
 *    lineHeight="120%"
 *    lineThrough="false"
 *    listStylePosition="outside"
 *    listStyleType="disc"
 *    locale="en"
 *    paragraphEndIndent="0"
 *    paragraphSpaceAfter="0"
 *    paragraphSpaceBefore="0"
 *    paragraphStartIndent="0"
 *    renderingMode="CFF"
 *    rollOverColor=""
 *    symbolColor=""
 *    tabStops="null"
 *    textAlign="start"
 *    textAlignLast="start"
 *    textAlpha="1"
 *    textDecoration="none"
 *    textIndent="0"
 *    textJustify="inter_word"
 *    textRotation="auto"
 *    trackingLeft="0"
 *    trackingRight="0"
 *    typographicCase="default"
 *    unfocusedTextSelectionColor=""
 *    verticalScrollPolicy="auto"
 *    whiteSpaceCollapse="collapse"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.core.IViewport
 *  @see spark.components.DataGroup
 *  @see spark.components.Group
 *  @see spark.components.RichEditableText
 *  @see spark.skins.spark.ScrollerSkin
 *
 *  @includeExample examples/ScrollerExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */

public class Scroller extends SkinnableComponent 
       implements IFocusManagerComponent, IVisualElementContainer
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Threshold for number of pixels they must move to count as a horizontal scroll
     */
    private static const MIN_HORIZONTAL_SLOP:int = 20;
    
    /**
     *  @private
     *  Threshold for number of pixels they must move to count as a vertical scroll
     */
    private static const MIN_VERTICAL_SLOP:int = 20;
    
    /**
     *  @private
     *  Threshold for number of pixels they must move to count as a diagonal scroll
     */
    private static const MIN_DIAGONAL_SLOP:int = 20;
    
    /**
     *  @private
     *  Length the touch scroll throw effect should run
     */
    private static const THROW_EFFECT_TIME:int = 2000;
    
    /**
     *  @private
     *  SDT - Scrollbar Display Threshold.  If the content size exceeds the
     *  viewport's size by SDT, then we show a scrollbar.  For example, if the 
     *  contentWidth >= viewport width + SDT, show the horizontal scrollbar.
     */
    mx_internal static const SDT:Number = 1.0;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Scroller()
    {
        super();
        hasFocusableChildren = true;
        focusEnabled = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables: Touch Scrolling
    //
    //--------------------------------------------------------------------------    
    
    /**
     *  @private
     *  Property used to communicate with ScrollerLayout to let it 
     *  know when a horizontal scroll is in progress or not (and when 
     *  the horizontal scroll bar should be hidden or not)
     */
    mx_internal var horizontalScrollInProgress:Boolean = false;
    
    /**
     *  @private
     *  Property used to communicate with ScrollerLayout to let it 
     *  know when a vertical scroll is in progress or not (and when 
     *  the vertical scroll bar should be hidden or not)
     */
    mx_internal var verticalScrollInProgress:Boolean = false;
    
    /**
     *  @private
     *  Touch Scroll Helper -- used to help figure out 
     *  scrolling velocity and other information
     */
    private var touchScrollHelper:TouchScrollHelper;
    
    /**
     *  @private
     *  Keeps track of the horizontal scroll position
     *  before scrolling started, so we can figure out 
     *  how to related it to the dragX that are 
     *  associated with the touchScrollDrag events.
     */
    private var hspBeforeTouchScroll:Number;
    
    /**
     *  @private
     *  Keeps track of the vertical scroll position
     *  before scrolling started, so we can figure out 
     *  how to related it to the dragY that are 
     *  associated with the touchScrollDrag events.
     */
    private var vspBeforeTouchScroll:Number;
    
    /**
     *  @private
     *  Effect used for touch scroll throwing
     */
    private var throwEffect:Animate;
    
    /**
     *  @private
     *  Easing object used for touch scroll throwing
     */
    private var throwEaser:TouchScrollingEasing;
    
    /**
     *  @private
     *  Used to keep track of whether the throw animation 
     *  was stopped pre-emptively.  We stop propogation of 
     *  the mouse event, but in the throwEffect.EFFECT_END
     *  event handler, we need to tell it not to exit the
     *  scrolling state.
     */
    private var stoppedPreemptively:Boolean = false;
    
    /**
     *  @private
     *  Used to keep track of whether we are currently throwing
     *  vertically.  This is so on effect update we can perhaps stop 
     *  the effect pre-emptively since we are not doing pull 
     *  or spring effects yet.
     */
    private var scrollingVertically:Boolean;
    
    /**
     *  @private
     *  Used to keep track of whether we are currently throwing
     *  horizontally.  This is so on effect update we can perhaps stop 
     *  the effect pre-emptively since we are not doing pull 
     *  or spring effects yet.
     */
    private var scrollingHorizontally:Boolean;
    
    /**
     *  @private
     *  Animation to fade the scrollbars out when we are done
     *  throwing or dragging
     */
    private var hideScrollBarAnimation:Animate;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private function invalidateSkin():void
    {
        if (skin)
        {
            skin.invalidateSize()
            skin.invalidateDisplayList();
        }
    }    
    
    //----------------------------------
    //  horizontalScrollBar
    //---------------------------------- 
    
    [SkinPart(required="false")]
    [Bindable]    

    /**
     *  A skin part that defines the horizontal scroll bar.
     * 
     *  This property should be considered read-only. It is only
     *  set by the Scroller's skin.
     * 
     *  This property is Bindable.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var horizontalScrollBar:HScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart(required="false")]
    [Bindable]
    
    /**
     *  A skin part that defines the vertical scroll bar.
     * 
     *  This property should be considered read-only. It is only
     *  set by the Scroller's skin.
     * 
     *  This property is Bindable.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var verticalScrollBar:VScrollBar;


    //----------------------------------
    //  viewport - default property
    //----------------------------------    
    
    private var _viewport:IViewport;
    
    [Bindable(event="viewportChanged")]
    
    /**
     *  The viewport component to be scrolled.
     * 
     *  <p>
     *  The viewport is added to the Scroller component's skin, 
     *  which lays out both the viewport and scroll bars.
     * 
     *  When the <code>viewport</code> property is set, the viewport's 
     *  <code>clipAndEnableScrolling</code> property is 
     *  set to true to enable scrolling.
     * 
     *  The Scroller does not support rotating the viewport directly.  The viewport's
     *  contents can be transformed arbitrarily, but the viewport itself cannot.
     * </p>
     * 
     *  This property is Bindable.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get viewport():IViewport
    {       
        return _viewport;
    }
    
    /**
     *  @private
     */
    public function set viewport(value:IViewport):void
    {
        if (value == _viewport)
            return;
        
        uninstallViewport();
        _viewport = value;
        installViewport();
        dispatchEvent(new Event("viewportChanged"));
    }

    private function installViewport():void
    {
        if (skin && viewport)
        {
            viewport.clipAndEnableScrolling = true;
            Group(skin).addElementAt(viewport, 0);
            viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
        if (verticalScrollBar)
            verticalScrollBar.viewport = viewport;
        if (horizontalScrollBar)
            horizontalScrollBar.viewport = viewport;
    }
    
    private function uninstallViewport():void
    {
        if (horizontalScrollBar)
            horizontalScrollBar.viewport = null;
        if (verticalScrollBar)
            verticalScrollBar.viewport = null;        
        if (skin && viewport)
        {
            viewport.clipAndEnableScrolling = false;
            Group(skin).removeElement(viewport);
            viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
    }
    
    
    //----------------------------------
    //  minViewportInset
    //----------------------------------

    private var _minViewportInset:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The minimum space between the viewport and the edges of the Scroller.  
     * 
     *  If neither of the scroll bars is visible, then the viewport is inset by 
     *  <code>minViewportInset</code> on all four sides.
     * 
     *  If a scroll bar is visible then the viewport is inset by <code>minViewportInset</code>
     *  or by the scroll bar's size, whichever is larger.
     * 
     *  ScrollBars are laid out flush with the edges of the Scroller.   
     * 
     *  @default 0 
     */
    public function get minViewportInset():Number
    {
        return _minViewportInset;
    }

    /**
     *  @private
     */
    public function set minViewportInset(value:Number):void
    {
        if (value == _minViewportInset)
            return;
            
        _minViewportInset = value;
        invalidateSkin();
    }

    //----------------------------------
    //  measuredSizeIncludesScrollBars
    //----------------------------------
    
    private var _measuredSizeIncludesScrollBars:Boolean = true;
    
    /**
     *  If <code>true</code>, the Scroller's measured size includes the space required for
     *  the visible scroll bars, otherwise the Scroller's measured size depends
     *  only on its viewport.
     * 
     *  <p>Components like TextArea, which "reflow" their contents to fit the
     *  available width or height may use this property to stabilize their
     *  measured size.  By default a TextArea's is defined by its <code>widthInChars</code>
     *  and <code>heightInChars</code> properties and in many applications it's preferable
     *  for the measured size to remain constant, event when scroll bars are displayed
     *  by the TextArea skin's Scroller.</p>
     * 
     *  <p>In components where the content does not reflow, like a typical List's
     *  items, the default behavior is preferable because it makes it less
     *  likely that the component's content will be obscured by a scroll bar.</p>
     * 
     *  @default true
     */
    public function get measuredSizeIncludesScrollBars():Boolean
    {
        return _measuredSizeIncludesScrollBars;
    }
    
    /**
     *  @private 
     */
    public function set measuredSizeIncludesScrollBars(value:Boolean):void
    {
        if (value == _measuredSizeIncludesScrollBars)
            return;

        _measuredSizeIncludesScrollBars = value;
        invalidateSkin();
    }   
    
    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        switch(event.property) 
        {
            case "contentWidth": 
            case "contentHeight": 
                invalidateSkin();
                break;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IVisualElementContainer
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns 1 if there is a viewport, 0 otherwise.
     * 
     *  @return The number of visual elements in this visual container
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numElements():int
    {
        return viewport ? 1 : 0;
    }
    
    /**
     *  Returns the viewport if there is a viewport and the 
     *  index passed in is 0.  Otherwise, it throws a RangeError.
     *
     *  @param index The index of the element to retrieve.
     *
     *  @return The element at the specified index.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementAt(index:int):IVisualElement
    {
        if (viewport && index == 0)
            return viewport;
        else
            throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index]));
    }
    
    /**
     *  Returns 0 if the element passed in is the viewport.  
     *  Otherwise, it throws an ArgumentError.
     *
     *  @param element The element to identify.
     *
     *  @return The index position of the element to identify.
     * 
     *  @throws ArgumentError If the element is not a child of this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementIndex(element:IVisualElement):int
    {
        if (element != null && element == viewport)
            return 0;
        else
            throw ArgumentError(resourceManager.getString("components", "elementNotFoundInScroller", [element]));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child. 
     *  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElementAt(index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child. Use the <code>viewport</code> property to manipulate 
     *  it.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeAllElements():void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Touch scrolling methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Add touch listeners
     */
    private function installTouchListeners():void
    {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_STARTING, touchScrollStartingHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_START, touchScrollStartHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_DRAG, touchScrollDragHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_END, touchScrollEndHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW, touchScrollThrowHandler);
    }
    
    /**
     *  @private
     */
    private function uninstallTouchListeners():void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_STARTING, touchScrollStartingHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_START, touchScrollStartHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_END, touchScrollEndHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_DRAG, touchScrollDragHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW, touchScrollThrowHandler);
    }
    
    /**
     *  @private
     *  Helper function to determine whether the viewport scrolls horizontally
     */
    mx_internal function get shouldScrollHorizontally():Boolean
    {
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var viewportW:Number = isNaN(explicitViewportW) ? (viewport.width - (minViewportInset * 2)) : explicitViewportW;
        
        return viewport.contentWidth >= (viewportW + SDT);
    }
    
    /**
     *  @private
     *  Helper function to determine whether the viewport scrolls vertically
     */
    mx_internal function get shouldScrollVertically():Boolean
    {
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
        var viewportH:Number = isNaN(explicitViewportH) ? (viewport.height - (minViewportInset * 2)) : explicitViewportH;
        
        return viewport.contentHeight >= (viewportH + SDT);
    }
    
    /**
     *  @private
     *  Add event handlers while the scroll/throw animation is going on to 
     *  capture the mouse down handlers and deal with it ourselves
     */
    private function installSwallowingMouseHandlers():void
    {
        // block click events from occuring on me
        addEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        addEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
    }
    
    /**
     *  @private
     *  Remove event handlers after scroll/throw animation is done.
     */
    private function uninstallSwallowingMouseHandlers():void
    {
        removeEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        removeEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
    }
    
    /**
     *  @private
     *  Set up the effect to be used for the throw animation
     *  FIXME (rfrishbe): this could use some work
     */
    private function setUpThrowEffect(velocityX:Number, velocityY:Number):void
    {
        // create throwEffect if we haven't already
        if (!throwEffect)
        {
            throwEffect = new Animate();
            throwEffect.addEventListener(EffectEvent.EFFECT_END, throwEffect_effectEndHandler);
            throwEffect.addEventListener(EffectEvent.EFFECT_UPDATE, throwEffect_effectUpdateHandler);
            throwEffect.target = viewport;
            throwEffect.duration = THROW_EFFECT_TIME;
            
            // effect and easer stuff should be combined some or maybe we just need one 
            // touch specific class rather than two
            throwEaser = new TouchScrollingEasing(0);
            
            throwEffect.easer = throwEaser;
        }
        
        // calculate the finalVSP/finalHSP
        var finalHSP:Number = viewport.horizontalScrollPosition;
        var finalVSP:Number = viewport.verticalScrollPosition;
        
        // want velocity to be 0 and to decrease by currentFriction every 
        // SCROLLING_TIMER_DELAY over EFFECT_TIME total
        var decelerationRateX:Number = velocityX/THROW_EFFECT_TIME;
        var decelerationRateY:Number = velocityY/THROW_EFFECT_TIME;
        
        // figure out where we're scrolling to
        if (getStyle("horizontalScrollPolicy") == "on" || 
            (getStyle("horizontalScrollPolicy") == "auto" && shouldScrollHorizontally))
        {
            var hsp:Number = viewport.horizontalScrollPosition;
            var viewportWidth:Number = isNaN(viewport.width) ? 0 : viewport.width;
            var cWidth:Number = viewport.contentWidth;
            var maxWidth:Number = Math.max(0, (cWidth == 0) ? viewport.horizontalScrollPosition : cWidth - viewportWidth);
            
            // FORMULA: initialVelocity.y * ellapsedTime - (0.5 * frictionToUse * ellapsedTime * ellapsedTime);
            finalHSP = viewport.horizontalScrollPosition - (velocityX * THROW_EFFECT_TIME) + (.5 * decelerationRateX * THROW_EFFECT_TIME * THROW_EFFECT_TIME);
            
        }
        
        if (getStyle("verticalScrollPolicy") == "on" || 
            (getStyle("verticalScrollPolicy") == "auto" && shouldScrollVertically))
        {
            var vsp:Number = viewport.verticalScrollPosition;
            var viewportHeight:Number = isNaN(viewport.height) ? 0 : viewport.height;
            var cHeight:Number = viewport.contentHeight;
            var maxHeight:Number = Math.max(0, (cHeight == 0) ? viewport.verticalScrollPosition : cHeight - viewportHeight);
            
            // FORMULA: initialVelocity.y * ellapsedTime - (0.5 * frictionToUse * ellapsedTime * ellapsedTime);
            finalVSP = viewport.verticalScrollPosition - (velocityY * THROW_EFFECT_TIME) + (.5 * decelerationRateY * THROW_EFFECT_TIME * THROW_EFFECT_TIME);
        }
        
        // set up easer for the the throw
        throwEaser.velocityX = velocityX;
        throwEaser.velocityY = velocityY;
        throwEaser.maxVSP = maxHeight;
        throwEaser.maxHSP = maxWidth;
        
        // maybe use motion paths with more keyframes for the bounce effect??
        
        var throwEffectMotionPaths:Vector.<MotionPath> = new Vector.<MotionPath>();
        
        // set up a simple motion path for the animation from our current hsp/vsp to
        // the final hsp/vsp.
        if (getStyle("horizontalScrollPolicy") == "on" || 
            (getStyle("horizontalScrollPolicy") == "auto" && shouldScrollHorizontally))
        {
            var horizontalMP:MotionPath = new SimpleMotionPath("horizontalScrollPosition", hsp, finalHSP);
            throwEffectMotionPaths.push(horizontalMP);
            scrollingHorizontally = true;
        }
        else
        {
            scrollingHorizontally = false;
        }
        
        if (getStyle("verticalScrollPolicy") == "on" || 
            (getStyle("verticalScrollPolicy") == "auto" && shouldScrollVertically))
        {
            var verticalMP:MotionPath = new SimpleMotionPath("verticalScrollPosition", vsp, finalVSP);
            throwEffectMotionPaths.push(verticalMP);
            scrollingVertically = true;
        }
        else
        {
            scrollingVertically = false;
        }
        
        throwEffect.motionPaths = throwEffectMotionPaths;
    }
    
    /**
     *  @private
     *  When the throw or drag scroll is over, we should play a nice 
     *  animation to hide the scrollbars.
     */
    private function hideScrollBars():void
    {
        // FIXME (rfrishbe): need to make sure this coordinates with ScrollerLayout
        // better.
        if (!hideScrollBarAnimation)
        {
            hideScrollBarAnimation = new Animate();
            hideScrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
            hideScrollBarAnimation.duration = 500;
            var alphaMP:Vector.<MotionPath> = Vector.<MotionPath>([new SimpleMotionPath("alpha", 1, 0)]);
            hideScrollBarAnimation.motionPaths = alphaMP;
        }
        
        // set up the target scrollbars (hsb and/or vsb)
        var targets:Array = [];
        if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            targets.push(horizontalScrollBar);
        }
        
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            targets.push(verticalScrollBar);
        }
        
        hideScrollBarAnimation.play(targets);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
        
        if (allStyles || styleProp == "horizontalScrollPolicy" || 
            styleProp == "verticalScrollPolicy")
        {
            invalidateSkin();
        }
        
        if (allStyles || styleProp == "inputMode")
        {
            if (getStyle("inputMode") == "touch")
            {
                installTouchListeners();
                
                if (!touchScrollHelper)
                {
                    touchScrollHelper = new TouchScrollHelper(this);
                    touchScrollHelper.horizontalSlop = MIN_HORIZONTAL_SLOP;
                    touchScrollHelper.verticalSlop = MIN_VERTICAL_SLOP;
                    touchScrollHelper.diagonalSlop = MIN_DIAGONAL_SLOP;
                }
            }
            else
            {
                uninstallTouchListeners();
            }
        }
    }

    /**
     *  @private
     */
    override protected function attachSkin():void
    {
        super.attachSkin();
        Group(skin).layout = new ScrollerLayout();
        installViewport();
        skin.addEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
    }
    
    /**
     *  @private
     */
    override protected function detachSkin():void
    {    
        uninstallViewport();
        Group(skin).layout = null;
        skin.removeEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
        super.detachSkin();
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == verticalScrollBar)
            verticalScrollBar.viewport = viewport;
        
        else if (instance == horizontalScrollBar)
            horizontalScrollBar.viewport = viewport;
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == verticalScrollBar)
            verticalScrollBar.viewport = null;
        
        else if (instance == horizontalScrollBar)
            horizontalScrollBar.viewport = null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        super.keyDownHandler(event);

        var vp:IViewport = viewport;
        if (!vp || event.isDefaultPrevented())
            return;

        // If a TextField has the focus, then assume it will handle all keyboard
        // events, and that it will not use Event.preventDefault().
        if (getFocus() is TextField)
            return;
    
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            var vspDelta:Number = NaN;
            switch (event.keyCode)
            {
                case Keyboard.UP:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.UP);
                     break;
                case Keyboard.DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.DOWN);
                     break;
                case Keyboard.PAGE_UP:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.PAGE_UP);
                     break;
                case Keyboard.PAGE_DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.PAGE_DOWN);
                     break;
                case Keyboard.HOME:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.HOME);
                     break;
                case Keyboard.END:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.END);
                     break;
            }
            if (!isNaN(vspDelta))
            {
                vp.verticalScrollPosition += vspDelta;
                event.preventDefault();
            }
        }

        if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            var hspDelta:Number = NaN;
            switch (event.keyCode)
            {
                case Keyboard.LEFT:
                    hspDelta = (layoutDirection == LayoutDirection.LTR) ?
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT) :
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT);
                    break;
                case Keyboard.RIGHT:
                    hspDelta = (layoutDirection == LayoutDirection.LTR) ?
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT) :
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT);
                    break;
                case Keyboard.HOME:
                    hspDelta = vp.getHorizontalScrollPositionDelta(NavigationUnit.HOME);
                    break;
                case Keyboard.END:                
                    hspDelta = vp.getHorizontalScrollPositionDelta(NavigationUnit.END);
                    break;
                // If there's no vertical scrollbar, then map page up/down to
                // page left,right
                case Keyboard.PAGE_UP:
                     if (!verticalScrollBar || !(verticalScrollBar.visible)) 
                     {
                         hspDelta = (LayoutDirection.LTR) ?
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT) :
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT);
                     }
                     break;
                case Keyboard.PAGE_DOWN:
                     if (!verticalScrollBar || !(verticalScrollBar.visible)) 
                     {
                         hspDelta = (LayoutDirection.LTR) ?
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT) :
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT);
                     }
                     break;
            }
            if (!isNaN(hspDelta))
            {
                vp.horizontalScrollPosition += hspDelta;
                event.preventDefault();
            }
        }
    }
    
    private function skin_mouseWheelHandler(event:MouseEvent):void
    {
        const vp:IViewport = viewport;
        if (event.isDefaultPrevented() || !vp || !vp.visible)
            return;
            
        var nSteps:uint = Math.abs(event.delta);
        var navigationUnit:uint;

        // Scroll event.delta "steps".  If the VSB is up, scroll vertically,
        // if -only- the HSB is up then scroll horizontally.
         
        // TODO: The problem is that viewport.validateNow() doesn’t necessarily 
        // finish the job, see http://bugs.adobe.com/jira/browse/SDK-25740.   
        // Since some imprecision in mouse-wheel scrolling is tolerable this is
        // ok for now.  For 4.next we should add Scroller API for (reliably) 
        // scrolling in different increments and refactor code like this to 
        // depend on it.  Also applies to VScroller and HScroller mouse
        // handlers.
        
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            navigationUnit = (event.delta < 0) ? NavigationUnit.DOWN : NavigationUnit.UP;
            for (var vStep:int = 0; vStep < nSteps; vStep++)
            {
                var vspDelta:Number = vp.getVerticalScrollPositionDelta(navigationUnit);
                if (!isNaN(vspDelta))
                {
                    vp.verticalScrollPosition += vspDelta;
                    if (vp is IInvalidating)
                        IInvalidating(vp).validateNow();
                }
            }
            event.preventDefault();
        }
        else if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            navigationUnit = (event.delta < 0) ? NavigationUnit.RIGHT : NavigationUnit.LEFT;
            for (var hStep:int = 0; hStep < nSteps; hStep++)
            {
                var hspDelta:Number = vp.getHorizontalScrollPositionDelta(navigationUnit);
                if (!isNaN(hspDelta))
                {
                    vp.horizontalScrollPosition += hspDelta;
                    if (vp is IInvalidating)
                        IInvalidating(vp).validateNow();
                }
            }
            event.preventDefault();
        }            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers: Touch Scrolling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Event handler dispatched when someone is about to start scrolling.
     */
    private function touchScrollStartingHandler(event:TouchScrollEvent):void
    {
        // if it's us, don't do anything
        // if it's someone else and we've started scrolling, cancel this event
        // if it's someone else and we haven't started scrolling, don't do anything
        // here yet. Worry about it in the touchScrollStartHandler().
        if (event.scrollingObject != this && (horizontalScrollInProgress || verticalScrollInProgress))
        {
            event.preventDefault();
        }
    }
    
    /**
     *  @private
     *  Event handler dispatched when someone has started scrolling.
     */
    private function touchScrollStartHandler(event:TouchScrollEvent):void
    {
        if (event.scrollingObject != this)
        {
            // if it's not us scrolling, abort our scrolling attempt
            touchScrollHelper.stopScrollWatch();
        }
        else
        {
            // we are scrolling
            installSwallowingMouseHandlers();
            hspBeforeTouchScroll = viewport.horizontalScrollPosition;
            vspBeforeTouchScroll = viewport.verticalScrollPosition;
            
            if (getStyle("horizontalScrollPolicy") == "on" || 
                (getStyle("horizontalScrollPolicy") == "auto" && shouldScrollHorizontally))
            {
                horizontalScrollInProgress = true;
            }
            
            if (getStyle("verticalScrollPolicy") == "on" || 
                (getStyle("verticalScrollPolicy") == "auto" && shouldScrollVertically))
            {
                verticalScrollInProgress = true;
            }
            
            // need to invaliadte the ScrollerLayout object so it'll update the
            // scrollbars in overlay mode
            skin.invalidateDisplayList();
            
            // make sure our alpha is set back to normal from hideScrollBarAnimation
            if (hideScrollBarAnimation && hideScrollBarAnimation.isPlaying)
                hideScrollBarAnimation.pause();
            if (horizontalScrollBar)
            {
                horizontalScrollBar.alpha = 1;
            }
            
            if (verticalScrollBar)
            {
                verticalScrollBar.alpha = 1;
            }
        }
    }
    
    /**
     *  @private
     *  Event listeners added while a scroll/throw animation is in effect
     */
    private function touchScrolling_captureMouseHandler(event:MouseEvent):void
    {
        switch(event.type)
        {
            case MouseEvent.MOUSE_DOWN:
                if (throwEffect && throwEffect.isPlaying)
                {
                    // stop the effect.  we don't want to move it to its final value...we want to stop it in place
                    // FIXME (rfrishbe): however if it's below 0 or above maxVSP, we should snap it to these values
                    stoppedPreemptively = true;
                    throwEffect.stop();
                    
                    // get new values in case we start scrolling again
                    hspBeforeTouchScroll = viewport.horizontalScrollPosition;
                    vspBeforeTouchScroll = viewport.verticalScrollPosition;
                }
                
                touchScrollHelper.startScrollWatch(event);
                event.stopImmediatePropagation();
                break;
            case MouseEvent.CLICK:
                event.stopImmediatePropagation();
                break;
        }
    }
    
    /**
     *  @private
     *  Mousedown listener that adds the other listeners to watch for a scroll.
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        // TODO (rfrishbe): if currently scrolling and we have spring/pull effects, 
        // we should stop scrolling and move the VSP/HSP in to range (0, maxVSP).
        
        touchScrollHelper.startScrollWatch(event);
    }
    
    /**
     *  @private
     */
    private function touchScrollDragHandler(event:TouchScrollEvent):void
    {
        var xMove:int = 0;
        var yMove:int = 0;
        
        if (getStyle("horizontalScrollPolicy") == "on" || 
            (getStyle("horizontalScrollPolicy") == "auto" && shouldScrollHorizontally))
        {
            xMove = event.dragX;
        }
        
        if (getStyle("verticalScrollPolicy") == "on" || 
            (getStyle("verticalScrollPolicy") == "auto" && shouldScrollVertically))
        {
            yMove = event.dragY;
        }
        
        // FIXME (rfrishbe): figure out how we want negative signs to work
        viewport.horizontalScrollPosition = hspBeforeTouchScroll - xMove;
        viewport.verticalScrollPosition = vspBeforeTouchScroll - yMove;
    }
    
    /**
     *  @private
     *  Used to get rid of the scrollbars early if they've hit the max or min values
     *  FIXME (rfrishbe): This should be baked in to the effect instead of in here
     */
    private function throwEffect_effectUpdateHandler(event:EffectEvent):void
    {
        if (shouldStopScrolling)
            throwEffect.stop();
    }
    
    /**
     *  @private
     *  Returns true if the animation should stop because we've gone passed 
     *  the scrolling bounds.  This is called form the throwEffect_effectUpdateHandler
     *  and before the throwEffect is started.  Ideally this logic should be baked in 
     *  to the effect itself.
     */ 
    private function get shouldStopScrolling():Boolean
    {
        if (scrollingVertically && scrollingHorizontally)
        {
            if ((viewport.horizontalScrollPosition <= 0 || viewport.horizontalScrollPosition >= throwEaser.maxHSP) && 
                (viewport.verticalScrollPosition <= 0 || viewport.verticalScrollPosition >= throwEaser.maxVSP))
            {
                return true;
            }
        }
        else if (scrollingVertically)
        {
            if (viewport.verticalScrollPosition <= 0 || viewport.verticalScrollPosition >= throwEaser.maxVSP)
            {
                return true;
            }
        }
        else if (scrollingHorizontally)
        {
            if (viewport.horizontalScrollPosition <= 0 || viewport.horizontalScrollPosition >= throwEaser.maxHSP)
            {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     *  @private
     */ 
    private function throwEffect_effectEndHandler(event:EffectEvent):void
    {
        // if we stopped the effect ourself (because someone pressed down), then let's not consider
        // this the end
        if (stoppedPreemptively)
            return;
        
        dispatchEvent(new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END));
    }
    
    /**
     *  @private
     */ 
    private function touchScrollThrowHandler(event:TouchScrollEvent):void
    {   
        stoppedPreemptively = false;
        setUpThrowEffect(event.velocityX, event.velocityY);
        
        if (!shouldStopScrolling)
        {
            // if we should throw, start the effect now
            throwEffect.play();
        }
        else
        {
            // otherwise, let's end it early and fake this event so the ScrollThrowHelper will 
            // know to stop scrolling and things will continue normally
            dispatchEvent(new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END));
        }
    }
    
    /**
     *  @private
     *  When the throw is over, no need to listen for mouse events anymore.
     *  Also, use this to hide the scrollbars.
     */
    private function touchScrollEndHandler(event:TouchScrollEvent):void
    {
        uninstallSwallowingMouseHandlers();
        
        hideScrollBars();
    }
    
    /**
     *  @private
     *  Called when the effect finishes playing on the scrollbars.  This is so ScrollerLayout 
     *  can hide the scrollbars completely and go back to controlling its visibility.
     *  FIXME (rfrishbe): Not sure if this return to ScrollerLayout control is 
     *  actually necessary
     */
    private function hideScrollBarAnimation_effectEndHandler(event:EffectEvent):void
    {
        // now get rid of the scrollbars visibility
        horizontalScrollInProgress = false;
        verticalScrollInProgress = false;
        
        // need to invaliadte the ScrollerLayout object so it'll update the
        // scrollbars in overlay mode
        skin.invalidateDisplayList();
    }

}

}

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.getTimer;

import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.events.TouchScrollEvent;
import mx.utils.GetTimerUtil;

import spark.components.Scroller;

use namespace mx_internal;

/**
 *  @private
 *  Helper class to handle some of the touch scrolling logic.  Specifically
 *  it is used to handle some of the mouse tracking and velocity calculations.
 */
class TouchScrollHelper
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Number of mouse movements to keep in the history to calculate 
     *  velocity.
     */
    private static const HISTORY:int = 5;
    
    /**
     *  @private
     *  Minimum velocity needed to start a throw gesture
     */
    private static const MIN_START_VELOCITY:Number = 0.05;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper function used to calculate velocity from a set of
     *  points and a set of time values for when those points occurred.
     * 
     *  <p>The size of clickHistory and timeHistory should be the same.  
     *  The size of the returned array should have one less item.</p>
     */
    private static function calculateVelocity(clickHistory:Vector.<Point>, timeHistory:Vector.<int>):Vector.<Point>
    {
        var len:int = clickHistory.length - 1;
        if (len <= 0)
            
            return null;
        
        var velocities:Vector.<Point> = new Vector.<Point>(len);
        
        for (var i:int = 0; i < len; i++)
        {
            var point1:Point = clickHistory[i];
            var point2:Point = clickHistory[i+1];
            var distance:Point = point2.subtract(point1);
            var time:Number = timeHistory[i+1] - timeHistory[i];
            velocities[i] = new Point(distance.x/time, distance.y/time);
        }
        
        return velocities;
    }
    
    /**
     *  @private
     *  Helper function that takes an vector of points and a vector
     *  of weights and creates a weighted average from them.</p>
     */
    private static function averagePoints(points:Vector.<Point>, weighted:Vector.<Number>):Point
    {
        var len:int = points.length;
        
        var currentPoint:Point = new Point(0, 0);
        var totalWeight:Number = 0;
        
        for (var i:int = 0; i < len; i++)
        {
            var point:Point = new Point(points[i].x, points[i].y);
            totalWeight += weighted[i];
            point.x *= weighted[i];
            point.y *= weighted[i];
            currentPoint.x += point.x;
            currentPoint.y += point.y;
        }
        
        currentPoint.x = currentPoint.x/totalWeight;
        currentPoint.y = currentPoint.y/totalWeight;
        
        return currentPoint;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function TouchScrollHelper(scroller:Scroller)
    {
        super();
        
        mouseEventCoordinatesHistory = new Vector.<Point>();
        mouseEventTimeHistory = new Vector.<int>();
        
        this.scroller = scroller;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Horizontal slop - the scrolling threshold (minimum number of 
     *  pixels needed to move before a scroll gesture is recognized
     */
    public var horizontalSlop:Number;
    
    /**
     *  @private
     *  Vertical slop - the scrolling threshold (minimum number of 
     *  pixels needed to move before a scroll gesture is recognized
     */
    public var verticalSlop:Number;
    
    /**
     *  @private
     *  Diagonal slop - the scrolling threshold (minimum number of 
     *  pixels needed to move before a scroll gesture is recognized
     */
    public var diagonalSlop:Number;
    
    /**
     *  @private
     *  Reference to the Scroller associated with this ScrollThrowHelper
     */
    public var scroller:Scroller;
    
    /**
     *  @private
     *  The point that was moused downed on for this scroll gesture
     */
    private var mouseDownedPoint:Point;
    
    /**
     *  @private
     *  The point that a scroll was recognized from.
     * 
     *  <p>This is different from mouseDownedPoint because the user may 
     *  mousedown on one point, but a scroll isn't recognized until 
     *  they move more than the slop.  Because of this, we don't want
     *  the delta scrolled to be calculated from the mouseDowned point 
     *  because that would look jerky the first time a scroll occurred.</p>
     */
    private var scrollStartPoint:Point;
    
    /**
     *  @private
     *  The time the scroll started
     */
    private var startTime:Number;
    
    /**
     *  @private
     *  The displayObject that was mousedowned on.
     */
    private var mouseDownedDisplayObject:DisplayObject;
    
    /**
     *  @private
     *  Keeps track of the coordinates where the mouse events 
     *  occurred.  We use this for velocity calculation along 
     *  with timeHistory.
     */
    private var mouseEventCoordinatesHistory:Vector.<Point>;
    
    /**
     *  @private
     *  A history of times the last few mouse events occurred.
     *  We keep HISTORY objects in memory, and we use this mouseEventTimeHistory
     *  Vector along with mouseEventCoordinatesHistory to determine the velocity
     *  a user was moving their fingers.
     */
    private var mouseEventTimeHistory:Vector.<int>;
    
    /**
     *  @private
     *  Whether we are currently in a scroll gesture or not.
     */
    private var isScrolling:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Starts watching for a scroll operation.  This should take either 
     *  MouseEvent.MOUSE_DOWN or TouchEvent.TOUCH_BEGIN, but for now, only
     *  mousedown works.
     */
    public function startScrollWatch(event:Event):void
    {
        // this is the point from which all deltas are based.
        startTime = GetTimerUtil.getTimerFunction();
        
        if (event is MouseEvent && event.type == MouseEvent.MOUSE_DOWN)
        {
            var mouseEvent:MouseEvent = event as MouseEvent;
            
            if (!isScrolling)
            {
                this.mouseDownedDisplayObject = mouseEvent.target as DisplayObject;
                
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            installMouseListeners();
            
            // if we were already scrolling, continue scrolling
            if (isScrolling)
            {
                scrollStartPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            // store last 5 values
            mouseEventCoordinatesHistory.length = 0;
            mouseEventTimeHistory.length = 0;
            
            addMouseEventHistory(mouseEvent);
        }
        else if (event is TouchEvent && event.type == TouchEvent.TOUCH_BEGIN)
        {
            // TouchEvent case
            // TODO (rfrishbe)
        }            
    }
    
    /**
     *  @private
     *  Starts watching for a scroll operation.
     */
    public function stopScrollWatch():void
    {
        uninstallMouseListeners();
    }
    
    /**
     *  @private
     *  Adds the time and mouse coordinates for this event in to 
     *  our mouse event history so that we can use it later to 
     *  calculate velocity.
     * 
     *  @return the delta moved between this mouse event and the start
     *          of the scroll gesture.
     */
    private function addMouseEventHistory(event:MouseEvent):Point
    {
        var p:Point = new Point(event.stageX, event.stageY);
        var differencePoint:Point = p.subtract(mouseDownedPoint);
        
        // only store the last 5
        if (mouseEventCoordinatesHistory.length >= HISTORY)
        {
            mouseEventCoordinatesHistory.shift();
            mouseEventTimeHistory.shift();
        }
        
        mouseEventCoordinatesHistory.push(differencePoint);
        mouseEventTimeHistory.push(GetTimerUtil.getTimerFunction() - startTime);
        
        return differencePoint;
    }

    /**
     *  @private
     *  Installs mouse listeners to determine how far we've moved.
     */
    private function installMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.addEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(true);
    }
    
    /**
     *  @private
     */
    private function uninstallMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        // mouse events added in installMouseListeners()
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  If we are not scrolling, this is used to determine whether we should start 
     *  scrolling or not by checking if we've moved more than the slop.
     *  If we are scrolling, this is used to dispatch TouchScrollEvent.TOUCH_SCROLL_DRAG
     *  events and to determine how far the user has scrolled.
     */
    protected function sbRoot_mouseMoveHandler(event:MouseEvent):void
    {
        var mouseDownedDifference:Point = addMouseEventHistory(event);
        
        if (!isScrolling)
        {
            var shouldBeScrolling:Boolean = false;
            
            var possibleScrollHorizontally:Boolean = false;
            var possibleScrollVertically:Boolean = false;
            
            // figure out if we can even scroll horizontally or vertically
            if (scroller.getStyle("horizontalScrollPolicy") == "on" || 
                (scroller.getStyle("horizontalScrollPolicy") == "auto" && scroller.shouldScrollHorizontally))
            {
                possibleScrollHorizontally = true;
            }
            
            if (scroller.getStyle("verticalScrollPolicy") == "on" || 
                (scroller.getStyle("verticalScrollPolicy") == "auto" && scroller.shouldScrollVertically))
            {
                possibleScrollVertically = true;
            }
            
            // now figure out if we should scroll horizontally or vertically based on our slop
            if (possibleScrollHorizontally && possibleScrollVertically)
                shouldBeScrolling = Math.abs(mouseDownedDifference.length) >= diagonalSlop;
            else if (possibleScrollHorizontally)
                shouldBeScrolling = Math.abs(mouseDownedDifference.x) >= horizontalSlop;
            else if (possibleScrollVertically)
                shouldBeScrolling = Math.abs(mouseDownedDifference.y) >= verticalSlop;
            
            // If we should be scrolling, start scrolling
            if (shouldBeScrolling)
            {
                // Dispatch a cancellable and bubbling event to notify others
                var scrollDragStartingEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_STARTING, true, true);
                scrollDragStartingEvent.scrollingObject = scroller;
                var eventAccepted:Boolean = mouseDownedDisplayObject.dispatchEvent(scrollDragStartingEvent);
                
                // if the event was preventDefaulted(), then stop scrolling scrolling
                if (!eventAccepted)
                {                    
                    // TODO (rfrishbe): do we need to call updateAfterEvent() here and below?
                    event.updateAfterEvent();
                    
                    // calling stopScrollWatch() will remove all the appropriate listeners
                    stopScrollWatch();
                    
                    return;
                }
                
                // if the event has been accepted, then dispatch a bubbling start event
                var scrollDragStartEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_START);
                scrollDragStartEvent.scrollingObject = scroller;
                scroller.dispatchEvent(scrollDragStartEvent);
                
                // FIXME (rfrishbe): the difference should not be from the original point but from the slop.
                // otherwise we "jump" on the first move.
                // we should reset startPoint here to be this point minus slop (in the direction that caused the scroll)
                scrollStartPoint = new Point(event.stageX, event.stageY);
                isScrolling = true;
                
                // velocity calculations come from mouseDownedPoint.  The drag ones com from scrollStartPoint.
            }
            
            
        }
        
        // if we are scrolling (even if we just started scrolling)
        if (isScrolling)
        {
            // calculate the delta
            var p:Point = new Point(event.stageX, event.stageY);
            var scrollDifferencePoint:Point = p.subtract(scrollStartPoint);
            
            // dispatch the event
            var scrollDragEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_DRAG, false, false);
            scrollDragEvent.scrollingObject = scroller;
            scrollDragEvent.dragX = scrollDifferencePoint.x;
            scrollDragEvent.dragY = scrollDifferencePoint.y;
            
            scroller.dispatchEvent(scrollDragEvent);
            event.updateAfterEvent();
        }
    }
    
    /**
     *  @private
     *  Called when the user releases the mouse/touches up
     */
    protected function sbRoot_mouseUpHandler(event:Event):void
    {
        uninstallMouseListeners();
        
        // If we weren't already scrolling, then let's not start scrolling now
        if (!isScrolling)
            return;
        
        // This could be a SanboxMouseEvent
        if (event is MouseEvent)
            addMouseEventHistory(event as MouseEvent);
        
        // decide about throw
        
        // pad click and timeHistory if needed
        var currentTime:Number = GetTimerUtil.getTimerFunction();
        
        // calculate average time b/w events and see if the last two (mouseMove and this mouseUp) 
        // were far apart.  If they were, then don't do anything if the velocity of them is small.
        var averageTime:Number = 0;
        var len:int = mouseEventTimeHistory.length;
        
        // gauranteed to have 2 mouse events b/c atleast a mousedown and a mousemove 
        // because if there was no mousemove, we definitely would not be scrolling and 
        // would have exited this function earlier
        for (var i:int = 0; i < len - 2; i++)
        {
            averageTime += mouseEventTimeHistory[i+1] - mouseEventTimeHistory[i];
        }
        averageTime /= len-2;
        
        // use the amount they've used as well as the velocity to denote how far to throw the list.
        // to do this, we multiply by the ratio of how far they moved with respect to the screen size 
        // available size of the scroller.
        
        // allow 0% faster if they used everything
        const RATIO_TO_USE:Number = 1.0;
        
        // for the max size, we couldn't decide between using screen width/height or 
        // scroller width/height, so we're using a weighted average for it
        // FIXME (rfrishbe): use stage.stageWidth, stage.width, root.width, or FlexGlobals.topLevelApplication.width?
        var widthToUseForRatio:Number = (2*scroller.width + scroller.stage.width)/3;
        var heightToUseForRatio:Number = (2*scroller.height + scroller.stage.height)/3;
        var lastMouseEventPoint:Point = mouseEventCoordinatesHistory[len-1];
        var movedRatio:Point = new Point(Math.abs(RATIO_TO_USE*lastMouseEventPoint.x/widthToUseForRatio), Math.abs(RATIO_TO_USE*lastMouseEventPoint.y/heightToUseForRatio));

        // calculate the last velocity and make sure there was no pause that occurred
        var lastTime:Number = mouseEventTimeHistory[len-1] - mouseEventTimeHistory[len-2];
        var lastVelocity:Point = lastMouseEventPoint.subtract(mouseEventCoordinatesHistory[len-2]);
        lastVelocity.x /= lastTime;
        lastVelocity.y /= lastTime;
        lastVelocity.x *= movedRatio.x;
        lastVelocity.y *= movedRatio.y;
        
        var scrollEndEvent:TouchScrollEvent;
        
        // FIXME (rfrishbe): should be minXVelocity, minYVelocity, minDiagonalVelocity
        // FIXME (rfrishbe): this should be parameterized better and the heuristic should 
        // be documented better
        if ( (lastTime >= 3*averageTime) &&
            (lastVelocity.length <= MIN_START_VELOCITY))
        {
            isScrolling = false;
            
            // don't do anything
            scrollEndEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
            scrollEndEvent.scrollingObject = scroller;
            scroller.dispatchEvent(scrollEndEvent);
            return;
        }
        
        // calculate the velocity using a weighted average
        var velocities:Vector.<Point> = calculateVelocity(mouseEventCoordinatesHistory, mouseEventTimeHistory);
        var velocityWeights:Vector.<Number> = Vector.<Number>([1,1.33,1.66,2]);
        var throwVelocity:Point = averagePoints(velocities, velocityWeights);
        
        // use ratio of how far they scrolled to scale the velocity
        throwVelocity.x *= movedRatio.x;
        throwVelocity.y *= movedRatio.y;
        
        // if the velocity is greater than the minimum velocity, start throwing
        if (throwVelocity.length > MIN_START_VELOCITY)
        {
            var scrollEndAndThrowEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_THROW, false, false);
            scrollEndAndThrowEvent.scrollingObject = scroller;
            scrollEndAndThrowEvent.velocityX = throwVelocity.x;
            scrollEndAndThrowEvent.velocityY = throwVelocity.y;
            
            // wait for the animation to be over so we can dispatch a touchScrollEnd event
            scroller.addEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END, scroller_touchScrollThrowAnimationEnd);
            scroller.dispatchEvent(scrollEndAndThrowEvent);
        }
        else
        {
            // otherwise, end the scroll operation
            isScrolling = false;

            // don't do anything
            scrollEndEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
            scrollEndEvent.scrollingObject = scroller;
            scroller.dispatchEvent(scrollEndEvent);
        }
    }
    
    /**
     *  @private
     *  When the touchScrollThrow is over, we should dispatch a touchScrollEnd.
     */
    private function scroller_touchScrollThrowAnimationEnd(event:TouchScrollEvent):void
    {
        scroller.removeEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END, scroller_touchScrollThrowAnimationEnd);
        
        isScrolling = false;
        
        var scrollEndEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
        scrollEndEvent.scrollingObject = scroller;
        scroller.dispatchEvent(scrollEndEvent);
    }
    
    
}
