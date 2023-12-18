# Mobile habit tracker

# Links

[Figma Design](https://www.figma.com/file/owAO4CAPTJdpM1BZU5JHv7/Tracker-(YP)?t=SZDLmkWeOPX4y6mp-0)

# Purpose and goals of the app

The app helps users to form healthy habits and monitor their fulfillment.

Purposes of the app:

- Monitoring habits by day of the week;
- Viewing progress on habits;

# Brief description of the app

- The app consists of card trackers that the user creates. He can specify a title, category and set a schedule. Emoji and color can also be selected to distinguish the cards from each other.
- The cards are sorted by category. The user can search for them with search and filter them.
- With the calendar, the user can see what habits they have scheduled for a particular day.
- The app has statistics that shows the user's success rates, progress and averages.

## Functional requirements

## Onboarding

When a user first logs into the application, they are taken to the onboarding screen.

**The onboarding screen contains:**

1. A splash screen;
2. Title and secondary text;
3. Page controls;
4. A "This is technology" button.

**Algorithms and available actions:**

1. By swiping left and right, the user can switch between pages. The page controls change state when the page is switched;
2. By swiping "This is Technology" the user goes to the home screen. 

## Creating a habit card

On the main screen, the user can create a tracker for a habit or irregular event. A habit is an event that repeats with a certain frequency. An irregular event is not tied to specific days.

**The habit tracker creation screen contains:**

1. The screen title;
2. A field to enter the name of the tracker;
3. Category section;
4. Schedule setting section;
5. Emoji section;
6. Tracker color selection section;
7. Cancel button;
8. The "Create" button.

**The Create Tracker screen for an irregular event contains:**

1. Screen title;
2. A field for entering the name of the tracker;
3. Category section;
4. Emoji section;
5. Tracker color selection section;
6. Cancel button;
7. The "Create" button.

**Алгоритмы и доступные действия:**

**Algorithms and available actions:**

1. User can create a tracker for a habit or irregular event. The algorithm for creating trackers is similar, but the event does not have a schedule section.
2. The user can enter a name for the tracker;
    1. After entering one character, a cross icon appears. By clicking on the icon user can delete the entered text;
    2. The maximum number of characters is 38;
    3. If the user exceeds the allowed number of characters, an error text appears;
3. Clicking on the "Category" section opens the category selection screen;
    1. If the user has not added a category before, there is a stopper;
    2. A blue checkmark marks the last selected category;
    3. By clicking on "Add Category" the user can add a new category. 
        1. A screen will open with a field for entering a name. The "Done" button is inactive;
        2. If at least 1 character is entered, the "Done" button becomes active;
        3. Clicking the "Done" button closes the category creation screen and returns the user to the category selection screen. The created category appears in the list of categories. There is no automatic selection, no checkmarking.
        4. When a category is clicked, it is marked with a blue check mark and the user returns to the habit creation screen. The selected category is displayed on the habit creation screen in secondary text under the heading "Category";
4. In the habit creation mode, there is a "Schedule" section. Clicking on the section opens a screen with a selection of days of the week. The user can toggle the switcher to select a day to repeat the habit;
    1. Clicking on "Done" returns the user to the habit creation screen. The selected days are displayed on the habit creation screen with secondary text under the "Schedule" heading;
        1. If the user selected all days, the text "Every Day" is displayed;
5. The user can select an emoji. A backing text appears under the selected emoji;
6. The user can select the color of the tracker. A stroke appears on the selected color;
7. The user can stop creating the habit by clicking the "Cancel" button;
8. The "Create" button is inactive until all sections are filled in. Pressing the button opens the main screen. The created habit is displayed in the corresponding category;

## View Home Screen

The main screen allows the user to view all created trackers for the selected date, edit them and view statistics.

**Main screen contains:**

1. A "+" button to add a habit;
2. The "Trackers" heading;
3. The current date;
4. A field to search for trackers;
5. Trackers cards by categories. The cards contain:
    1. Emoji;
    2. The name of the tracker;
    3. Number of days tracked;
    4. A button to mark the habit performed;
6. The "Filter" button;
7. Tab-bar.

**Algorithms and available actions:**

1. When you click on the "+", a curtain pops up with the option to create a habit or irregular event;
2. When clicking on a date, a calendar pops up. The user can switch between months. When tapping on a number, the app shows trackers corresponding to the date;
3. User can search trackers by name in the search box;
    1. If nothing is found, the user sees a stub;
4. When user clicks on "Filters", a curtain with a list of filters pops up;
    1. There is no filter button if there are no trackers on the selected day;
    2. When selecting "All trackers" the user sees all trackers for the selected day;
    3. When selecting "Trackers for today" the current date is set and the user sees all trackers for this day;
    4. When selecting "Completed" the user sees the habits that have been completed by the user on the selected day;
    5. When "Not Completed" is selected, the user sees the uncompleted trackers on the selected day;
    6. The current filter is indicated by a blue check mark;
    7. When clicking on a filter, the curtain is hidden and the corresponding trackers are displayed;
        1. If nothing is found, the user sees a stub;
5. When scrolling down and up, the user can view the feed;
    1. If the card image has not had time to load, the system loader is displayed;
6. When you click on a card, the background below it blurs and a modal window pops up;
    1. The user can pin the card. The card will be placed in the "Pinned" category at the top of the list;
        1. The user can unhook the card by clicking again;
        2. If there are no pinned cards, there is no "Pinned" category;
    2. The user can edit the card. A modal window pops up with functionality similar to creating a card;
    3. When clicking on "Delete" the action sheet pops up.
        1. The user can confirm the deletion of the card. All data about the card should be deleted;
        2. The user can cancel the action and return to the main screen; 
7. Using the tab bar, the user can switch between "Trackers" and "Statistics" sections.

## Edit and Delete Category

While creating a tracker, the user can edit the categories in the list or delete unnecessary ones.

**Algorithms and available actions:**

1. When you long press on a category from the list, the background under it blurs and a modal window appears;
    1. If you click on "Edit", a modal window pops up. The user can edit the name of the category. If you click on "Done", the user returns to the list of categories;
    2. When clicking on "Delete" an action sheet pops up. 
        1. The user can confirm the deletion of the category. All data about it should be deleted;
        2. The user can cancel the action; 
        3. After confirming or canceling, the user returns to the category list;

## View Statistics

In the statistics tab, the user can view success rates, their progress, and averages.

**The statistics screen contains:**

1. The "Statistics" heading;
2. A list with statistical indicators. Each indicator contains:
    1. Header-number;
    2. Secondary text with the name of the indicator;
3. Tab-bar

**Algorithms and available actions:**

1. If there is no data for any indicator, the user sees a stub;
2. If there is data for at least one indicator, the statistics are displayed. Stats without data are displayed with a null value;
3. The user can view statistics for the following indicators:
    1. "Best period" counts the maximum number of days without interruption for all trackers;
    2. "Perfect days" counts the days when all scheduled habits were accomplished;
    3. "Trackers completed" counts the total number of completed habits for the entire time;
    4. "Average" counts the average number of habits completed in 1 day.

## Dark Theme.

The app has a dark theme that changes depending on the device's system settings.

## Non-functional requirements

1. The app must support iPhone X and above and adapted for iPhone SE, the minimum supported operating system version is iOS 13.4;
2. The app uses the standard iOS font - SF Pro.
3. Core Data is used to store data about habits.
