(import pandas
        [numpy :as np]
        [matplotlib.pyplot :as plt])

(defn parse-csv [filepath kwargs]
  (apply pandas.read_csv [filepath] kwargs))

(defn books-in-year [dataframe year]
  (let [[day1 (fn [y] (+ (str y) "-01-01"))]]
    (slice (. dataframe ix) (day1 year) (day1 (inc year)))))

(defn aggregate-by-month [dataframe params]
  "Group a particular key by month"
  (-> (.groupby dataframe (. dataframe index month)) (.aggregate params)))

(defn plot-month-pages [dataframe]
  (apply dataframe.plot [] {"kind" "bar" "width" 0.8 "color" ""})
  (plt.xlabel "month →")
  (plt.ylabel "Page Count →")
  (plt.savefig "pages-per-month.png"))

(defn process [filepath]
  (let [[df (parse-csv filepath
                   {"usecols" ["Title" "Date Read" "Bookshelves"
                               "Number of Pages"
                               "Original Publication Year"]
                              "parse_dates" ["Date Read"]
                              "index_col" "Date Read"})]
        [books-in-2014 (books-in-year df 2014)]
        [pages-per-month (-> (. books-in-2014 [["Number of Pages"]])
                             (aggregate-by-month ["sum" "count" np.mean]))]]
    (print pages-per-month)
    (plot-month-pages (. pages-per-month ["Number of Pages"] ["sum"]))))

(defmain [&rest args]
  (process (get args 1)))
