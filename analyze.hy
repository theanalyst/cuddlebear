(import pandas)

(defn parse-csv [filepath kwargs]
  (apply pandas.read_csv [filepath] kwargs))

(defn books-in-year [dataframe year]
  (let [[day1 (fn [y] (+ (str y) "-01-01"))]]
    (slice (. dataframe ix) (day1 year) (day1 (inc year)))))

(defn aggregate-by-month [dataframe params]
  "Group a particular key by month"
  (-> (.groupby dataframe (. dataframe index month)) (.aggregate params)))

(if (= --name-- "__main__")
  (let [[df (parse-csv "goodreads_export.csv"
                   {"usecols" ["Title" "Date Read" "Bookshelves"
                               "Number of Pages"
                               "Original Publication Year"]
                              "parse_dates" ["Date Read"]
                              "index_col" "Date Read"})]
        [books-in-2014 (books-in-year df 2014)]]
    (print (aggregate-by-month (. books-in-2014 [["Number of Pages"]]) '[sum count]))))
