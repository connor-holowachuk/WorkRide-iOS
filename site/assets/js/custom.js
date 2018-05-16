/* ============================================================
 * Plugin Core Init
 * For DEMO purposes only. Extract what you need.
 * ============================================================ */

'use strict';

$(document).ready(function() {

    //Intialize Slider
    var slider = new Swiper('#demo-hero-3 .swiper-container', {
        pagination: '.swiper-pagination',
        paginationClickable: true,
        nextButton: '.swiper-button-next',
        prevButton: '.swiper-button-prev',
        parallax: true,
        speed: 1000
    });

    //Intialize Testamonials
    var testimonials_slider = new Swiper('#demo-testimonial-1 .swiper-container', {
        pagination: '.swiper-pagination',
        paginationClickable: true,
        nextButton: '.swiper-button-next',
        prevButton: '.swiper-button-prev',
        parallax: true,
        speed: 1000
    });

})