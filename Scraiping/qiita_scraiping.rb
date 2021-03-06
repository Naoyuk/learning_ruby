require 'open-uri'
require 'nokogiri'
require 'csv'

# 検索ワードを配列で持ちます。
search_terms = ['ruby', 'php', 'python', 'perl']

results = {}

search_terms.each do |search_term|
  query_hash = []
  # 検索結果一覧ページが１００ページまでしか無いので１から１００にしています。
  (1..100).each do |i|
    # URLはベタがきではなく、「ページ番号」と「検索ワード」に式展開を使い、柔軟にしています。
    url = "https://qiita.com/search?page=#{i}&q=#{search_term}&sort=like"
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    # 「.searchResult」にタイトルやタグなどの親クラスで、各記事の情報がぶら下っているので、一度ここを取得し、ここから子クラスの情報を抽出します。
    # ここからはRubyというより、CSSセレクタの内容になります。欲しい情報に応じてHTMLタグやクラスを書き換えてください。検証ツールで確認できます。
    doc.search('.searchResult').each do |node|
      tags = []
      title = node.css('.searchResult_itemTitle').text
      node.css('.tagList_item').each{ |article_tag| tags << article_tag.text }
      details = node.css('.searchResult_snippet').text
      link = "https://qiita.com/" + node.css('.searchResult_itemTitle').css('a')[0][:href]
      # [0]が「良いね」の数。[1]は「コメント」の数
      stars = node.css('.list-unstyled.list-inline.searchResult_statusList li')[0].text.gsub(" ","")
      # コメント数が０個の場合は、コメントのHTML要素が出力されない為、[1]のところでNilエラーになります。それを回避する為にアンパサンドを使用します。
      comments = node.css('.list-unstyled.list-inline.searchResult_statusList li')[1]&.text&.gsub(" ","")
      author = node.css('.searchResult_header').css('a')&.text
      query_hash << { stars: stars, title: title, tags: tags, details: details, link: link, comments: comments, author: author }
    end
    # この一連の処理は時間がかかります。ここでputsすることで、処理がどれぐらい進んでいるかを確認しながら待つことができます。
    puts "#{search_term} #{i}"
  end
  results["#{search_term}"] = query_hash

end



# resultsというハッシュに入った結果を一元配列で管理し、結果をCSV出力する。
ruby_array, php_array, python_array, perl_array = [], [], [], []

results["ruby"].each do |a|
  ruby_array << [ a[:stars], a[:title], a[:tags], a[:details], a[:link], a[:comments], a[:author] ]
end
# CSV.openの引数に、書き出すファイル名を指定します。その際にLinuxコマンドのようにPathで指定すれば任意の場所に保存できます。
CSV.open('qiita_ruby.csv', 'w') do |csv|
  # ヘッダーの設定
  csv << ['stars', 'title', 'tags', 'details', 'link', 'comments', 'author']
  ruby_array.each do |r|
    csv << r
  end
end

results["php"].each do |a|
  php_array << [ a[:stars], a[:title], a[:tags], a[:details], a[:link], a[:comments], a[:author] ]
end
CSV.open('qiita_php.csv', 'w') do |csv|
  # ヘッダーの設定
  csv << ['stars', 'title', 'tags', 'details', 'link', 'comments', 'author']
  php_array.each do |r|
    csv << r
  end
end

results["python"].each do |a|
  python_array << [ a[:stars], a[:title], a[:tags], a[:details], a[:link], a[:comments], a[:author] ]
end
CSV.open('Desktop/qiita_python.csv', 'w') do |csv|
  # ヘッダーの設定
  csv << ['stars', 'title', 'tags', 'details', 'link', 'comments', 'author']
  python_array.each do |r|
    csv << r
  end
end

results["perl"].each do |a|
  perl_array << [ a[:stars], a[:title], a[:tags], a[:details], a[:link], a[:comments], a[:author] ]
end
CSV.open('Desktop/qiita_perl.csv', 'w') do |csv|
  # ヘッダーの設定
  csv << ['stars', 'title', 'tags', 'details', 'link', 'comments', 'author']
  perl_array.each do |r|
    csv << r
  end
end

