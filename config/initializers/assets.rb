# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css.scss, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( mouse_over_ele_select.js )
Rails.application.config.assets.precompile += %w( Math.uuid.js )
Rails.application.config.assets.precompile += %w( robot.coffee )
Rails.application.config.assets.precompile += %w( node.coffee )
Rails.application.config.assets.precompile += %w( node_svg.coffee )
Rails.application.config.assets.precompile += %w( jquery-impromptu.js )
Rails.application.config.assets.precompile += %w( jquery-impromptu.css )
Rails.application.config.assets.precompile += %w( myApp.js )
Rails.application.config.assets.precompile += %w( scrape2.js )
