# Peak Hills

This applications takes the activities completed by a particular Strava user and cross references them with a list of hills in the Peak District or Lake District to calculate which they've climbed.

## Installation

### 1. Create the database

The SQL scripts for creating the database can be found in `db/create_tables.sql`.

### 2. Create an environment variable for the Strava API key

The app expects to find an environment variable called `PEAK_HILLS_STRAVA_KEY`. This is the API key for a Strava app that's been granted permission to read activity data on the users account. 

### 3. Scrape the hills in the Peak District from Wikipedia

Run `rake wikipedia:scrape`. This scrapes [Wikipedia's list of hills in the peak district](https://en.wikipedia.org/wiki/List_of_hills_in_the_Peak_District) then scrapes the data on this webpage's table into the database table **hills**.

### 4. Insert the Wainwrights, from JSON.

Run `rake json:push_wainwrights`. This pushes the data contained within `data/wainwrights.json` into the database table **hills**.

### 5. Download the Strava activity data

Run `rake strava:download_activities`. This pulls all of the activity data for the the user associated with the key in step 2. This data gets inserted into the database table **activities**.

### 6. Calculate intersections

Run `rake geo:calculate_intersections`. This cycles through the **activities** in the database, looking firstly if they appear in the Peak District or the Lake District, and if they do, if they intersect the summit any of the **hills**.

### 7. Create excursions as necessary

Next, you should create excursions. These are simply a way of grouping activities together, for example the three days spent cycling The Way of The Roses. They are stored as a file on disk, for ease of creation (rather than a database table). `exursions.json` takes the format:

```
[
  {
    "id": 1,
    "name": "The Way of The Roses",
    "activities": [
      691164953,
      692571453,
      693200525
    ]
  },
  ...
]
```

### 8. Generate the HTML pages and JSON files for the website

Finally we're in a position to create the HTML interface to the site. You do this by running the following:

```
rake site:generate_hill_html_files
rake site:generate_activity_pages
rake site:generate_excursion_html_files
rake site:generate_excursion_activity_json_files
```

### 9. Deploy to the Pi

```
make install
```

## To-do

- Add a way to write up activity descriptions such that generating the activity pages doesn't trash the content.
