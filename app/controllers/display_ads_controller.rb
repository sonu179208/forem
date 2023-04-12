class DisplayAdsController < ApplicationController
  before_action :set_cache_control_headers, only: %i[for_display], unless: -> { current_user }
  CACHE_EXPIRY_FOR_DISPLAY_ADS = 15.minutes.to_i.freeze

  def show
    skip_authorization
    set_cache_control_headers(CACHE_EXPIRY_FOR_DISPLAY_ADS) unless session_current_user_id

    if params[:placement_area]
      if params[:username].present? && params[:slug].present?
        @article = Article.find_by(slug: params[:slug])
      end

      @display_ad = DisplayAd.for_display(
        area: params[:placement_area],
        user_signed_in: user_signed_in?,
        organization_id: @article&.organization_id,
        permit_adjacent_sponsors: ArticleDecorator.new(@article).permit_adjacent_sponsors?,
        article_tags: @article&.decorate&.cached_tag_list_array || [],
        article_id: @article&.id,
      )

      if @display_ad && !session_current_user_id
        set_surrogate_key_header @display_ad.record_key
      end
    end

    render layout: false
  end
end