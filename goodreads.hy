(import pandas
        [numpy :as np]
        [matplotlib.pyplot :as plt]
        [seaborn :as sns])

(defn parse-goodreads-csv [filepath]
  (let [[required-fields ["Title" "Date Read" "Bookshelves"
                          "Number of Pages" "Original Publication Year"]]]
    (pandas.read_csv filepath :usecols required-fields :index-col "Date Read"
                     :parse-dates true)))

(defn books-in-year [dataframe year]
  (let [[day1 (fn [y] (+ (str y) "-01-01"))]]
    (slice (. dataframe ix) (day1 year) (day1 (inc year)))))

(defn aggregate-by-month [dataframe params]
  "Group a particular key by month"
  (-> (.groupby dataframe (. dataframe index month)) (.aggregate params)))

(defn plot-monthly-pages [dataframe]
  (sns.set :style "darkgrid")
  (plt.figure :figsize (, 8 6))
  (dataframe.plot :kind "bar")
  (plt.xlabel "month →")
  (plt.ylabel "Page Count →")
  (plt.savefig "pages-per-month.png"))

(defn process [filepath]
  (let [[required-fields ["Title" "Date Read" "Bookshelves"
                  "Number of Pages" "Original Publication Year"]]
        [books-in-2014
         (-> (parse-goodreads-csv filepath)
             (books-in-year 2014))]
        [pages-per-month (-> (. books-in-2014 [["Number of Pages"]])
                             (aggregate-by-month ["sum" "count" np.mean]))]]
    (print "Pages read in 2014 " ((. books-in-2014 ["Number of Pages"] sum)))
    (print "Pages read in kindle"
           ((. books-in-2014 [(= books-in-2014.Bookshelves "kindle")]
               ["Number of Pages"] sum)))
    (print "Monthly Stats")
    (print pages-per-month)
    (plot-monthly-pages (. pages-per-month ["Number of Pages"] ["sum"]))))

(defmain [&rest args]
  (process (get args 1)))
