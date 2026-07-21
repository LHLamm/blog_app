namespace :articles do
  desc "Backfill articles.status_tmp (integer) từ status (string) cũ - dùng khi có dữ liệu legacy cần convert"
  task backfill_status: :environment do
    status_map = { "draft" => 10, "published" => 20, "archived" => 30 }

    status_map.each do |string_value, int_value|
      updated = Article.where(status: string_value).update_all(status_tmp: int_value)
      puts "status='#{string_value}' -> status_tmp=#{int_value}: đã cập nhật #{updated} bản ghi"
    end

    puts "Hoàn tất backfill articles.status_tmp"
  end
end
