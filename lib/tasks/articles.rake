namespace :articles do
  desc "Backfill articles.status_tmp (integer) từ status (string) cũ - dùng khi có dữ liệu legacy cần convert"
  task backfill_status: :environment do
    status_map = { "draft" => 10, "published" => 20, "archived" => 30 }

    status_map.each do |string_value, int_value|
      sql = ActiveRecord::Base.sanitize_sql_array(
        [ "UPDATE articles SET status_tmp = ? WHERE status = ?", int_value, string_value ]
      )
      updated = ActiveRecord::Base.connection.update(sql)
      puts "status='#{string_value}' -> status_tmp=#{int_value}: đã cập nhật #{updated} bản ghi"
    end

    puts "Hoàn tất backfill articles.status_tmp"
  end
end
