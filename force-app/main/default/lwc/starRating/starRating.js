import { LightningElement, api } from 'lwc';

export default class StarRating extends LightningElement {

    @api value = 0;
    @api maxValue = 5;
    @api readOnly = false;

    get stars() {

        let result = [];

        for (let i = 1; i <= this.maxValue; i++) {

            result.push({
                id: i,
                class: i <= this.value
                    ? 'star filled'
                    : 'star'
            });
        }

        return result;
    }

    handleClick(event) {

        if (this.readOnly) {
            return;
        }

        this.value = Number(event.target.dataset.value);

        this.dispatchEvent(
            new CustomEvent('ratingchange', {
                detail: {
                    rating: this.value
                }
            })
        );
    }
}